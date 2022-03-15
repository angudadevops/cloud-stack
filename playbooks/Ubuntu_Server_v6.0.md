<h1> Cloud Native Core Ubuntu Server (x86-64) v6.0 </h1>

This page describes the steps required to use Ansible to install the Cloud Native Core.

The final Cloud Native Core will include:

- Ubuntu 20.04.3 LTS
- Containerd 1.6.0
- Kubernetes version 1.23.2
- Helm 3.8.0
- NVIDIA GPU Operator 1.9.1
  - NV containerized driver: 510.47.03
  - NV container toolkit: 1.7.2
  - NV K8S device plug-in: 0.10.0
  - Data Center GPU Manager (DCGM): 2.3.1-2.6.1
  - Node Feature Discovery: 0.8.2
  - GPU Feature Discovery: 0.4.1
  - K8s MIG Manager: 0.2.0
  - NVIDIA DGCM: 2.3.1
  - NVIDIA Driver Manager: 0.2.0
- NVIDIA Network Operator 1.1.0
  - Mellanox MOFED Driver 5.5-1.0.3.2
  - Mellanox NV Peer Memory Driver 1.1-0
  - RDMA Shared Device Plugin 1.2.1
  - SRIOV Device Plugin 3.3
  - Container Networking Plugins 0.8.7
  - Multus 3.8
  - Whereabouts 0.4.2

### Release Notes

- Added support for Multi Node Kubernetes Cluster

### The following Ansible Playbooks are available

- [Install Cloud Native Core](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/cnc-installation.yaml)

- [Validate Cloud Native Core ](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/cnc-validation.yaml)

- [Uninstall Cloud Native Core](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/cnc-uninstall.yaml)

## Prerequisites

- You have a NGC-Ready for Edge Server.
- You will perform a clean install.
- The server has internet connectivity.

To determine if your system is NGC-Ready for Edge Servers, please review the list of validated systems on the NGC-Ready Systems documentation page: https://docs.nvidia.com/ngc/ngc-ready-systems/index.html

Please note that the Cloud Native Core is only validated on Intel based NGC-Ready systems with the default kernel (not HWE). Using an AMD EPYC 2nd generation (ROME) NGC-Ready server is not validated yet and will require the HWE kernel and manually disabling nouveau.

### Installing the Ubuntu Operating System
These instructions require having Ubuntu Server LTS 20.04.3 on your NGC-Ready system. The Ubuntu Server can be downloaded from http://cdimage.ubuntu.com/releases/20.04.3/release/.


For more information on installing Ubuntu server please reference the [Ubuntu Server Installation Guide](https://ubuntu.com/tutorials/tutorial-install-ubuntu-server#1-overview).
 
## Using the Ansible playbooks 
This section describes how to use the ansible playbooks.

### Clone the git repository

Run the below commands to clone the CNC ansible playbooks.

```
git clone https://github.com/NVIDIA/egx-platform.git
cd egx-platform/playbooks
```

Update the hosts file in playbooks directory with master and worker nodes(if you have) IP's with username and password like below

```
nano hosts

[master]
10.110.16.178 ansible_ssh_user=nvidia ansible_ssh_pass=nvidipass ansible_sudo_pass=nvidiapass ansible_ssh_common_args='-o StrictHostKeyChecking=no'
[node]
10.110.16.179 ansible_ssh_user=nvidia ansible_ssh_pass=nvidiapass ansible_sudo_pass=nvidiapass ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```


## Available Cloud Native Core Versions

Update Cloud Native Core Version as per below, currently supported versions are

- [1.2](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/Ubuntu_Server_v1.2.md)
- [2.0](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/Ubuntu_Server_v2.0.md)
- [3.1](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/Ubuntu_Server_v3.1.md)
- [4.0](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/Ubuntu_Server_v4.0.md)
- [4.1](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/Ubuntu_Server_v4.1.md)
- [4.2](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/Ubuntu_Server_v4.2.md)
- [5.0](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/Ubuntu_Server_v5.0.md)
- [6.0](https://github.com/NVIDIA/egx-platform/blob/master/playbooks/Ubuntu_Server_v6.0.md)

```
nano cnc_values.yaml

cnc_version: 6.0

```

### Installation

Install the CNC stack by running the below command. "Skipping" in the ansible output refers to the Kubernetes cluster is up and running.

```
bash setup.sh install
```

### Validation

Run the below command to check if the installed versions are match with predefined versions of the Cloud Native Core. Here' "Ignored" tasks refer to failed and "Changed/Ok" tasks refer to success.

Run the validation playbook after 5 minutes once completing the Cloud Native Core Installation. Depends on your internet speed, you need to wait more time.

```
bash setup.sh validate
```

### Uninstall

Run the below command to uninstall the Cloud Native Core. Taks being "ignored" refers to no kubernetes cluster being available.

```
bash setup.sh uninstall
```

