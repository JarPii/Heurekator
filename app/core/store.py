from abc import ABC, abstractmethod
from pathlib import Path

from app.models import Session


class SessionStore(ABC):
    """Tallennusabstraktio. JSONFileStore riittää yhden käyttäjän/tiimin
    sisäiseen käyttöön; myöhempi siirto esim. SQLiteen ei vaadi muutoksia
    app.core.engine-moduuliin, koska se puhuu vain tätä rajapintaa vasten.
    """

    @abstractmethod
    def save(self, session: Session) -> None: ...

    @abstractmethod
    def load(self, session_id: str) -> Session: ...


class JSONFileStore(SessionStore):
    def __init__(self, directory: Path):
        self._directory = directory
        self._directory.mkdir(parents=True, exist_ok=True)

    def _path(self, session_id: str) -> Path:
        return self._directory / f"{session_id}.json"

    def save(self, session: Session) -> None:
        self._path(session.id).write_text(session.model_dump_json(indent=2), encoding="utf-8")

    def load(self, session_id: str) -> Session:
        data = self._path(session_id).read_text(encoding="utf-8")
        return Session.model_validate_json(data)
