# KubuQA

## Kubuntu ISO Testing Utility - Spin up VMs with ease

**New to Kubuntu Testing & Development ?** No worries, we have you covered!!

### Overview

This Bash script automates the process of setting up a test environment based off the latest daily build of Kubuntu.
It downloads all required files if necessary and facilitates launching a test installation using VirtualBox.
It leverages `kdialog` for graphical user interaction,
making it accessible even for users who prefer not to work with the command line directly.

## Installation

### Prerequisites

We assume you're working on Kubuntu, or another Ubuntu based Linux distribution.

In order to execute this script, the following tools need to be installed on your system:

- `kdialog` for graphical dialogs.
- `zsync` for ISO file updates.
- `wget` for downloading files.
- `VirtualBox` and `VBoxManage` for running the test installation.

The script includes a preliminary check and attempts to install any missing tools using `pkexec`.
You will be asked to authorize each installation with the root password.
_Please review the [KubuQA.sh](https://raw.githubusercontent.com/kubuntu-team/KubuQA/main/KubuQA.sh)
script to assure yourself of what is being installed._

### Downloading the Script

Clone this repository or download the script directly from the GitHub page:

#### Clone

```bash
git clone git@github.com:kubuntu-team/KubuQA.git
```

#### Download

```bash
wget -O KubuQA.sh https://raw.githubusercontent.com/kubuntu-team/KubuQA/main/KubuQA.sh 
```

Make the script executable:

```bash
chmod +x KubuQA.sh
```

### Usage

To run the script, simply execute it from the terminal:

```bash
./KubuQA.sh
```

The script will guide you through the following steps:

- Install all necessary programs it needs to run (see above)
- Set up the scaffold of the testing VM if necessary
- Create a Virtual Disk Image (VDI) if necessary
- Look for a KubuntuTestISO directory in your Downloads directory and create it if necessary
- Check if the `noble-desktop-amd64.iso` file exists within this directory:
  - If found, offer to check for updates using zsync.
  - If not found, prompt to download the ISO.
- Ask if you want to launch a test installation in VirtualBox.
If you choose Yes, a new VirtualBox VM will be started.
Please **make sure to select `ISO`** when starting up a freshly created VM,
since the VDI is empty and can't be used as boot device as long as there is no OS installed on it.

Upon subsequent runs, you may choose to boot from ISO or VDI, giving you the ability to Stop/Start your testing as desired.

For each of the steps that require user interaction, a `kdialog` prompt will appear to guide you through the process.

## Contributing

If you have ideas for additions or improvements please do create an Issue,
or open a Pull Request on our [Github KubuQA](https://github.com/kubuntu-team/KubuQA).

### Ideas (so far)

- [ ] [Introductory dialog that gives an overview of what is about to happen](https://github.com/kubuntu-team/KubuQA/issues/7)
- [ ] [Implement various variables to make the script more configurable and accessible](https://github.com/kubuntu-team/KubuQA/issues/8)
- [ ] [Make sure to validate the input](https://github.com/kubuntu-team/KubuQA/issues/9)
- [ ] [Provide an "Uninstall" option](https://github.com/kubuntu-team/KubuQA/issues/10)

## License

[License GPL v3.0](./License)
