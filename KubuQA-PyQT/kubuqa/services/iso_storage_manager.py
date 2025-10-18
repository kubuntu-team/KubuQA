"""Manage on-disk ISO artifacts and metadata."""

from __future__ import annotations

from pathlib import Path

from kubuqa.domain import IsoArtifact


class IsoStorageManager:
    """Coordinates location and metadata of ISO files on disk."""

    def __init__(self, root: Path) -> None:
        self._root = root

    @property
    def root(self) -> Path:
        """Return the root path for ISO storage."""
        return self._root

    def record_artifact(self, artifact: IsoArtifact) -> None:
        """Persist ISO metadata (implementation pending)."""
        raise NotImplementedError("IsoStorageManager.record_artifact is not yet implemented.")
