import json
import os
import time
from typing import Callable, Type, TypeVar

# mistralai 2.9.x:ssä top-level `mistralai` ei re-exporttaa Mistral-luokkaa (paketin
# oma __init__.py puuttuu) — asennetussa versiossa toimiva polku on tämä.
from mistralai.client import Mistral
from mistralai.client.errors.sdkerror import SDKError
from pydantic import BaseModel

from app.llm.base import LLMClient
from app.models import Message

T = TypeVar("T", bound=BaseModel)
R = TypeVar("R")

MAX_RETRIES = 5
BASE_DELAY_SECONDS = 2.0


class MistralClient(LLMClient):
    def __init__(self, api_key: str | None = None, model: str | None = None):
        resolved_key = api_key or os.environ.get("MISTRAL_API_KEY")
        if not resolved_key:
            raise RuntimeError(
                "MISTRAL_API_KEY puuttuu. Aseta se .env-tiedostoon tai ympäristömuuttujaksi."
            )
        self._client = Mistral(api_key=resolved_key)
        self._model = model or os.environ.get("MISTRAL_MODEL", "mistral-large-latest")

    @staticmethod
    def _to_mistral_messages(system: str, messages: list[Message]) -> list[dict]:
        return [{"role": "system", "content": system}] + [
            {"role": m.role, "content": m.content} for m in messages
        ]

    @staticmethod
    def _call_with_retry(call: Callable[[], R]) -> R:
        """Ilmaisten/matalan kiintiön Mistral-avainten 429 (rate limit) osuu
        herkästi kun samalla kierroksella tehdään kaksi peräkkäistä kutsua
        (kysymys + arviointi). Yritetään uudelleen Retry-After-otsikon tai
        eksponentiaalisen viiveen mukaan ennen luovuttamista.
        """
        for attempt in range(MAX_RETRIES):
            try:
                return call()
            except SDKError as error:
                status = getattr(error.raw_response, "status_code", None)
                if status != 429 or attempt == MAX_RETRIES - 1:
                    raise
                retry_after = error.raw_response.headers.get("retry-after")
                delay = float(retry_after) if retry_after else BASE_DELAY_SECONDS * (2**attempt)
                time.sleep(delay)
        raise AssertionError("unreachable")

    def complete_text(self, system: str, messages: list[Message]) -> str:
        response = self._call_with_retry(
            lambda: self._client.chat.complete(
                model=self._model,
                messages=self._to_mistral_messages(system, messages),
            )
        )
        return response.choices[0].message.content

    def complete_structured(self, system: str, messages: list[Message], schema: Type[T]) -> T:
        tool_name = schema.__name__
        response = self._call_with_retry(
            lambda: self._client.chat.complete(
                model=self._model,
                messages=self._to_mistral_messages(system, messages),
                tools=[
                    {
                        "type": "function",
                        "function": {
                            "name": tool_name,
                            "description": f"Palauta vastaus muodossa {tool_name}.",
                            "parameters": schema.model_json_schema(),
                        },
                    }
                ],
                tool_choice="any",
            )
        )
        message = response.choices[0].message
        if not message.tool_calls:
            raise RuntimeError(f"Malli ei palauttanut odotettua työkalukutsua: {tool_name}")

        arguments = message.tool_calls[0].function.arguments
        if isinstance(arguments, str):
            arguments = json.loads(arguments)
        return schema.model_validate(arguments)
