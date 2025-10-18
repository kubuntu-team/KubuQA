"""Coordinate ISO download or update jobs."""

from __future__ import annotations

from typing import Callable

from kubuqa.domain import IsoArtifact


class DownloadCoordinator:
    """Facade for background download orchestration."""

    def __init__(self) -> None:
        self._progress_callback: Callable[[int], None] | None = None

    def set_progress_callback(self, callback: Callable[[int], None]) -> None:
        """Register a callback for progress updates."""
        self._progress_callback = callback

    def download(self, artifact: IsoArtifact) -> None:
        """Start a download operation (implementation pending)."""
        raise NotImplementedError("DownloadCoordinator.download is not yet implemented.")
