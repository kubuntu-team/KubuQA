"""Abstractions for virtualization backends."""

from __future__ import annotations

from abc import ABC, abstractmethod

from kubuqa.domain import FlavorDefinition, IsoArtifact, VmProfile


class VirtualizationProvider(ABC):
    """Unified interface for different virtualization technologies."""

    id: str
    display_name: str

    @abstractmethod
    def is_available(self) -> bool:
        """Return True when the provider can be used on this system."""

    @abstractmethod
    def ensure_prerequisites(self) -> None:
        """Prepare host dependencies prior to VM launch."""

    @abstractmethod
    def prepare_vm(self, flavor: FlavorDefinition, profile: VmProfile, iso: IsoArtifact) -> None:
        """Create or update VM configuration ready for launch."""

    @abstractmethod
    def start_vm(self, flavor: FlavorDefinition, profile: VmProfile) -> None:
        """Start the prepared VM."""
