from pathlib import Path

from kubuqa.domain import FlavorDefinition, IsoArtifact, UserSettings, VmProfile


def test_vm_profile_defaults():
    profile = VmProfile(
        name_template="kubuqa-{flavor}",
        cpu_count=4,
        memory_mb=4096,
        video_ram_mb=128,
        paravirt_hint="kvm",
        disk_size_mb=32768,
    )

    assert profile.name_template == "kubuqa-{flavor}"
    assert profile.cpu_count == 4


def test_flavor_definition_round_trip():
    profile = VmProfile(
        name_template="kubuqa-{flavor}",
        cpu_count=2,
        memory_mb=2048,
        video_ram_mb=64,
        paravirt_hint="minimal",
        disk_size_mb=20480,
    )
    flavor = FlavorDefinition(
        id="kubuntu",
        display_name="Kubuntu",
        icon_path=Path("/tmp/kubuntu.svg"),
        release_url="https://releases.ubuntu.com/kubuntu.iso",
        daily_url="https://cdimage.ubuntu.com/kubuntu.iso",
        html_overview_path=Path("/tmp/kubuntu.html"),
        default_vm_profile=profile,
    )

    assert flavor.id == "kubuntu"
    assert flavor.default_vm_profile.cpu_count == 2


def test_iso_artifact_metadata():
    artifact = IsoArtifact(
        flavor_id="kubuntu",
        channel="daily",
        file_path=Path("/tmp/kubuntu.iso"),
        download_url="https://example.com/kubuntu.iso",
        checksum=None,
        last_updated=None,
        size_bytes=None,
    )

    assert artifact.file_path.name == "kubuntu.iso"


def test_user_settings_custom_extra():
    settings = UserSettings(
        iso_root=Path("/tmp/iso"),
        default_channel="daily",
        virtualization_provider_id="virtualbox",
        extra={"theme": "dark"},
    )

    assert settings.extra["theme"] == "dark"
