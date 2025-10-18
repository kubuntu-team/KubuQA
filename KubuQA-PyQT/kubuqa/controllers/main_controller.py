"""High-level application controller coordinating UI and services."""

from __future__ import annotations

from kubuqa.services import DownloadCoordinator, FlavorRegistry, IsoStorageManager, VirtualizationManager


class MainController:
    """Connects UI events to service layer actions."""

    def __init__(
        self,
        flavor_registry: FlavorRegistry,
        storage_manager: IsoStorageManager,
        download_coordinator: DownloadCoordinator,
        virtualization_manager: VirtualizationManager,
    ) -> None:
        self._flavor_registry = flavor_registry
        self._storage_manager = storage_manager
        self._download_coordinator = download_coordinator
        self._virtualization_manager = virtualization_manager

    def bootstrap(self) -> None:
        """Perform startup initialisation (implementation pending)."""
        raise NotImplementedError("MainController.bootstrap is not yet implemented.")
