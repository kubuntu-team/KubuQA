"""VM sizing defaults used when provisioning test machines."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class VmProfile:
    """Virtual machine resource defaults shared across providers."""

    name_template: str
    cpu_count: int
    memory_mb: int
    video_ram_mb: int
    paravirt_hint: str
    disk_size_mb: int
