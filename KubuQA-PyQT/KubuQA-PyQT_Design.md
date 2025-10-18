# KubuQA PyQt Architecture Plan

## 1. Objectives
- Deliver a PyQt-based desktop application that replicates and extends the current `KubuQA.sh` workflow.
- Provide a maintainable architecture for ISO download, zsync updates, and storage per Ubuntu flavour and release channel.
- Decouple virtualisation tooling (VirtualBox, Virtual Machine Manager/libvirt, future providers) behind a common abstraction exposed in the UI.
- Preserve user-friendliness with guided workflows, responsive feedback, and minimal manual configuration.

## 2. Existing Shell Workflow Snapshot
- Dependency bootstrap via `check_and_install_tool` for `kdialog`, `zsync`, `wget`, and `VBoxManage`.
- Interactive flavour/channel selection through `kdialog`; each choice maps to release/daily download URLs and VM names.
- ISO download/update lifecycle: ensure flavour-specific directory, download missing ISO via `wget`, refresh existing ISO via `zsync`.
- Virtual machine preparation: create/update VirtualBox VM, ensure VDI exists, attach ISO or disk, and start VM with post-start resolution tweak.
- Configuration is a flat shell script / sourced env file with variables for paths, VM resources, and ISO endpoints.

## 3. Target Application Architecture

### 3.1 Layered Structure
- **Presentation (PyQt)**: windows, dialogs, widgets, resource icons, HTML rendering, progress feedback.
- **Application Logic**: controllers orchestrating user actions, long-running jobs, and state transitions.
- **Domain / Services**: ISO download/update/storage services, flavour registry, virtualisation façade, settings persistence.
- **Infrastructure**: filesystem access, subprocess execution (`wget`, `zsync`, `VBoxManage`, `virt-install`), logging.

### 3.2 Project Layout (within `KubuQA-PyQT/`)
- `app.py`: entry point creating `QApplication` and wiring main window to services.
- `kubuqa/ui/`: Qt widgets, dialogs, resources.
- `kubuqa/domain/`: dataclasses for flavours, ISO metadata, VM profiles.
- `kubuqa/services/`: ISO lifecycle, download workers, virtualisation providers, settings manager, logging.
- `kubuqa/resources/`: icons, default HTML info pages per flavour.
- `tests/`: unit/integration tests (later implementation phase).

### 3.3 Core Domain Models
- `FlavorDefinition`: `id`, `display_name`, `icon_path`, `release_url`, `daily_url`, `html_overview_path`, `default_vm_profile`.
- `VmProfile`: `name_template`, `cpu_count`, `memory_mb`, `video_ram_mb`, `paravirt_hint`, `disk_size_mb`.
- `IsoArtifact`: `flavor_id`, `channel`, `file_path`, `download_url`, `checksum`, `last_updated`, `size_bytes`.
- `UserSettings`: serialization wrapper around persisted preferences (derived from `QSettings`) including ISO root path, default channel, virtualisation provider id, per-profile overrides.

### 3.4 ISO Lifecycle Services
- `FlavorRegistry`: singleton reading bundled JSON/YAML to expose available flavours and derived metadata.
- `IsoStorageManager`:
  - Computes on-disk paths (`<iso_root>/<flavor_id>/<channel>/<filename>`).
  - Maintains metadata file (`iso-state.json`) recording timestamps, checksums.
  - Exposes queries for installed ISOs and cleanup operations.
- `DownloadCoordinator`:
  - Orchestrates download/update via task queue.
  - Selects between full download (`wget`) and delta update (`zsync`) based on local file presence and config.
  - Emits `progress(int)`, `status(str)`, and `completed(IsoArtifact)` signals through Qt for UI binding.
  - Wraps command execution in cancellable worker threads (`QThreadPool` + `QRunnable`) with structured logging.
- `ChecksumVerifier` (future enhancement): optional SHA256 validation against published sums.

### 3.5 Virtualisation Abstraction
- `VirtualizationProvider` (abstract base class):
  - `id`, `display_name`, `is_available()`, `ensure_prerequisites()`, `prepare_vm(flavor: FlavorDefinition, profile: VmProfile, iso: IsoArtifact) -> VmInstance`.
  - `start_vm(instance: VmInstance, boot_medium: BootMedium)`.
  - `list_instances()` & `delete_instance()` for lifecycle management.
- Concrete providers:
  - `VirtualBoxProvider`: wraps `VBoxManage`, mirrors logic from shell script (create VM, storage controllers, attach ISO/VDI, set video mode).
  - `LibvirtProvider`: utilises `virt-install`/`virsh` or libvirt Python API; supports Virtual Machine Manager interoperability.
- `VirtualizationManager`: selects provider based on user settings, handles dropdown population, exposes provider capability flags to UI (e.g. snapshot support).
- Future providers (e.g. `QEMUProvider`) plug in via registration map without UI changes.

### 3.6 Settings and Persistence
- `SettingsManager` leveraging `QSettings` (`org.kubuntu.KubuQA` domain) for lightweight preferences (paths, defaults, UI state).
- Optional JSON config (`~/.config/kubuqa/flavors_override.json`) to extend/override shipped flavour definitions.
- Automatic creation of ISO root directory (`~/Downloads/KubuQATestISO` by default, user configurable).
- Store last-status snapshots for resuming partial downloads and displaying last action in status area.

### 3.7 UI Composition
- **Menus**:
  - `File`: `Quit`, future `Open Logs`.
  - `Edit`: placeholder for copy/paste of output or upcoming actions.
  - `Settings`: opens modal dialog with general tab (paths), virtualisation tab (dropdown: VirtualBox, Virtual Machine Manager) and VM resource defaults, flavours tab (channel default).
  - `Help`: `About`, `Documentation`, `Check Updates`.
- **Main Layout** (`MainWindow`):
  - Central widget is a vertical `QVBoxLayout`.
  - Top splitter (`QSplitter` horizontal):
    - Left (1/3): `FlavorListPanel` housing `QListWidget` or custom `QListView` with icon/text rows; clicking triggers flavour selection.
    - Right (2/3): `HtmlInfoView` (prefer `QTextBrowser` for offline HTML or `QWebEngineView` if richer content needed) loading local HTML snippet per flavour/channel.
  - Bottom status area (`QHBoxLayout`):
    - Left (1/3): `StatusPanel` showing `Status:` label bound to latest workflow message.
    - Right (2/3): `QProgressBar` with indeterminate mode for pre-download checks and determinate updates when progress known.
- Contextual action buttons (Download, Launch VM, Open ISO folder) presented near the info view or as toolbar under menus.

### 3.8 Controller Responsibilities
- `MainController`: owns `FlavorRegistry`, `SettingsManager`, `VirtualizationManager`, `DownloadCoordinator`; responds to UI signals.
- `DownloadController` (could be merged into `MainController`): ensures single active download, orchestrates status updates, handles cancellation.
- `LaunchController`: collects selected flavour/channel, ensures ISO availability, prompts for boot medium, delegates to current provider.
- Controllers emit high-level signals consumed by UI; UI remains thin (display-only).

### 3.9 Application Workflow
1. **Startup**: load settings, validate ISO root path, populate flavours list, detect available virtualisation providers (query `is_available()`), set default selections.
2. **Flavour Selection**: update HTML view (local docs), status resets, enable actions.
3. **Download/Update**:
   - Check for existing ISO metadata; choose `zsync` vs `wget`.
   - Run background task; update progress via Qt signals; on completion, refresh metadata and statuses.
4. **Launch VM**:
   - Ensure ISO exists or prompt to download.
   - Present boot medium choice (ISO vs disk) in modal dialog.
   - Call `prepare_vm` + `start_vm` on active provider.
   - Log operations; show success/failure toast via status label.
5. **Settings Change**: updates persisted immediately; when provider changes, re-evaluate availability and adjust UI warnings.

### 3.10 Async Execution & Error Handling
- Use `QThreadPool` with `QRunnable` tasks for subprocess operations; communicate via `pyqtSignal`.
- Graceful cancellation token for downloads to respond to user aborts.
- Structured logging (`logging` module) with optional log file view (future).
- Error surfaced through dialog stack plus status area, while storing diagnostics for support.

### 3.11 Extensibility & Future Work
- Package management for dependencies (offer to install missing tools via `pkexec` similar to current script).
- Optional integration with checksums/signatures.
- Telemetry hooks for download statistics (if desired).
- The same architecture can support ARM images or cloud images by adding new flavour definitions and provider capabilities.

