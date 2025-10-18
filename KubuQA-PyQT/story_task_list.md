# EPIC: Project Bootstrap & Infrastructure
- [ ] Initialize `KubuQA-PyQT` package structure with entry point and module layout
- [ ] Configure packaging/dependency metadata (pyproject, requirements)
- [ ] Set up logging, configuration loading, and application-wide constants
- [ ] Implement foundational unit test harness and CI hooks

# EPIC: ISO Lifecycle & Storage
- [ ] Implement flavour registry loading from bundled definitions
- [ ] Build ISO storage manager with metadata persistence
- [ ] Develop download coordinator with wget/zsync command runners
- [ ] Add checksum verification and failure recovery mechanisms

# EPIC: Virtualisation Abstraction
- [ ] Define virtualization provider interface and manager
- [ ] Implement VirtualBox provider parity with existing shell workflow
- [ ] Implement Libvirt provider for Virtual Machine Manager compatibility
- [ ] Create provider selection and capability detection logic

# EPIC: UI & Interaction
- [ ] Construct main window layout (menus, split panels, status/progress area)
- [ ] Implement flavour list widget with icons and selection handling
- [ ] Integrate HTML info view loading local documentation
- [ ] Wire download/launch actions to controllers with feedback dialogs

# EPIC: Settings & Persistence
- [ ] Implement QSettings-based settings manager with defaults
- [ ] Build settings dialog (paths, virtualisation, resource defaults)
- [ ] Persist per-flavour/channel preferences and last-state info
- [ ] Support user-provided flavour overrides

# EPIC: Testing, QA & Documentation
- [ ] Create integration tests for download and virtualization workflows (mocked commands)
- [ ] Document developer setup and contribution guidelines
- [ ] Add user-facing help and troubleshooting content
- [ ] Pilot release packaging and smoke test instructions

# EPIC: PyInstaller Packaging
- [ ] Evaluate PyInstaller project structure and entry point definition
- [ ] Create PyInstaller spec/build configuration for desktop application
- [ ] Automate PyInstaller packaging and artifact verification
- [ ] Document packaging workflow and distribution checklist
