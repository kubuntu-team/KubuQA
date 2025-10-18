"""Details about downloaded ISO assets."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from pathlib import Path


@dataclass(slots=True)
class IsoArtifact:
    """Represents a locally cached ISO image."""

    flavor_id: str
    channel: str
    file_path: Path
    download_url: str
    checksum: str | None
    last_updated: datetime | None
    size_bytes: int | None
