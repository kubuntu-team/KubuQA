"""Registry responsible for loading flavour definitions."""

from __future__ import annotations

from pathlib import Path
from typing import Iterable

from kubuqa.domain import FlavorDefinition


class FlavorRegistry:
    """Loads and exposes available flavour definitions."""

    def __init__(self, definitions: Iterable[FlavorDefinition] | None = None) -> None:
        self._definitions = list(definitions or [])

    def load_from_path(self, path: Path) -> None:
        """Load definitions from disk (implementation pending)."""
        raise NotImplementedError("FlavorRegistry.load_from_path is not yet implemented.")

    def all(self) -> list[FlavorDefinition]:
        """Return all registered flavours."""
        return list(self._definitions)
