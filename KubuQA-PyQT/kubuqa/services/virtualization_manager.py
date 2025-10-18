"""Manage available virtualization providers and selection state."""

from __future__ import annotations

from typing import Iterable

from .virtualization_provider import VirtualizationProvider


class VirtualizationManager:
    """Registry of virtualization providers, with helper lookups."""

    def __init__(self, providers: Iterable[VirtualizationProvider] | None = None) -> None:
        self._providers = {provider.id: provider for provider in providers or []}
        self._active_provider_id: str | None = None

    def register(self, provider: VirtualizationProvider) -> None:
        """Register a provider instance."""
        self._providers[provider.id] = provider

    def set_active(self, provider_id: str) -> None:
        """Select the provider to use for new operations."""
        if provider_id not in self._providers:
            raise KeyError(f"Provider '{provider_id}' is not registered.")
        self._active_provider_id = provider_id

    def active(self) -> VirtualizationProvider | None:
        """Return the active provider, if any."""
        if self._active_provider_id is None:
            return None
        return self._providers[self._active_provider_id]

    def available(self) -> list[VirtualizationProvider]:
        """Return providers that report availability."""
        return [provider for provider in self._providers.values() if provider.is_available()]
