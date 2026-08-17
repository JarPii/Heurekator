from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field

Verdict = Literal[
    "pinnallinen",
    "ristiriitainen",
    "puuttuva_nakokulma",
    "yksiulotteinen",
    "kestava",
]

Recommendation = Literal["jatka", "kehita_lisaa", "hylkaa"]


class Message(BaseModel):
    role: Literal["user", "assistant"]
    content: str


class CriterionScore(BaseModel):
    criterion: str
    score: int = Field(ge=1, le=5)
    comment: str


class Evaluation(BaseModel):
    verdict: Verdict
    scores: list[CriterionScore]
    identified_assumptions: list[str] = Field(default_factory=list)
    identified_risks: list[str] = Field(default_factory=list)
    contradiction_note: str | None = None
    rationale: str


class AreaProgress(BaseModel):
    area_id: str
    attempts: int = 0
    resolved: bool = False
    evaluations: list[Evaluation] = Field(default_factory=list)


class Report(BaseModel):
    concept_document_markdown: str
    recommendation: Recommendation
    recommendation_rationale: str


class Session(BaseModel):
    id: str
    idea: str
    status: Literal["active", "done"] = "active"
    current_area_index: int = 0
    history: list[Message] = Field(default_factory=list)
    areas: list[AreaProgress] = Field(default_factory=list)
    assumptions: list[str] = Field(default_factory=list)
    risks: list[str] = Field(default_factory=list)
    report: Report | None = None
