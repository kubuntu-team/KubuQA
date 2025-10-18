"""Representation of persisted user preferences."""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path


@dataclass(slots=True)
class UserSettings:
    """Lightweight view of configurable settings persisted via QSettings."""

    iso_root: Path
    default_channel: str
    virtualization_provider_id: str
    preferred_vm_profile: str | None = None
    extra: dict[str, str] = field(default_factory=dict)
