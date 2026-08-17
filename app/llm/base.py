from abc import ABC, abstractmethod
from typing import Type, TypeVar

from pydantic import BaseModel

from app.models import Message

T = TypeVar("T", bound=BaseModel)


class LLMClient(ABC):
    """Abstraktio LLM-kutsujen taakse.

    Tarkoituksella ohut rajapinta, jotta mallin/palveluntarjoajan vaihto tai
    kahden mallin (kysyjä/arvioija) käyttöönotto (vision §5) ei vaadi
    muutoksia orkestrointilogiikkaan (app.core.engine).
    """

    @abstractmethod
    def complete_text(self, system: str, messages: list[Message]) -> str:
        ...

    @abstractmethod
    def complete_structured(self, system: str, messages: list[Message], schema: Type[T]) -> T:
        ...
