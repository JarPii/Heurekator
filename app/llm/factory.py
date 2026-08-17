import os

from app.llm.base import LLMClient


def get_llm_client() -> LLMClient:
    """Valitsee LLM-toteutuksen LLM_PROVIDER-ympäristömuuttujan perusteella.

    Pitää app.main:n riippumattomana siitä, mitä palveluntarjoajaa käytetään —
    uuden tarjoajan lisääminen vaatii vain uuden LLMClient-toteutuksen tänne.
    """
    provider = os.environ.get("LLM_PROVIDER", "mistral").lower()

    if provider == "mistral":
        from app.llm.mistral_client import MistralClient

        return MistralClient()

    if provider == "anthropic":
        from app.llm.anthropic_client import AnthropicClient

        return AnthropicClient()

    raise RuntimeError(
        f"Tuntematon LLM_PROVIDER: '{provider}'. Tuetut arvot: 'mistral', 'anthropic'."
    )
