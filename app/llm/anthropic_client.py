import os
from typing import Type, TypeVar

from anthropic import Anthropic
from pydantic import BaseModel

from app.llm.base import LLMClient
from app.models import Message

T = TypeVar("T", bound=BaseModel)


class AnthropicClient(LLMClient):
    def __init__(self, api_key: str | None = None, model: str | None = None):
        resolved_key = api_key or os.environ.get("ANTHROPIC_API_KEY")
        if not resolved_key:
            raise RuntimeError(
                "ANTHROPIC_API_KEY puuttuu. Aseta se .env-tiedostoon tai ympäristömuuttujaksi."
            )
        self._client = Anthropic(api_key=resolved_key)
        self._model = model or os.environ.get("ANTHROPIC_MODEL", "claude-sonnet-5")

    def complete_text(self, system: str, messages: list[Message]) -> str:
        response = self._client.messages.create(
            model=self._model,
            max_tokens=1024,
            system=system,
            messages=[{"role": m.role, "content": m.content} for m in messages],
        )
        return "".join(block.text for block in response.content if block.type == "text")

    def complete_structured(self, system: str, messages: list[Message], schema: Type[T]) -> T:
        tool_name = schema.__name__
        response = self._client.messages.create(
            model=self._model,
            max_tokens=1536,
            system=system,
            messages=[{"role": m.role, "content": m.content} for m in messages],
            tools=[
                {
                    "name": tool_name,
                    "description": f"Palauta vastaus muodossa {tool_name}.",
                    "input_schema": schema.model_json_schema(),
                }
            ],
            tool_choice={"type": "tool", "name": tool_name},
        )
        for block in response.content:
            if block.type == "tool_use" and block.name == tool_name:
                return schema.model_validate(block.input)
        raise RuntimeError(f"Malli ei palauttanut odotettua työkalukutsua: {tool_name}")
