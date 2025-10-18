"""Data structures describing Kubuntu flavour metadata."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from .vm_profile import VmProfile


@dataclass(frozen=True, slots=True)
class FlavorDefinition:
    """Represents a Kubuntu flavour and its associated assets."""

    id: str
    display_name: str
    icon_path: Path
    release_url: str
    daily_url: str
    html_overview_path: Path
    default_vm_profile: VmProfile
