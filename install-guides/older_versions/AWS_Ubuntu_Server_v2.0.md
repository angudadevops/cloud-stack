<h1>Cloud Native Core v2.0(formely EGX Stack 2.0) for AWS - Install Guide for Ubuntu Server x86-64</h1>
<h2>Introduction</h2>
This document describes how to set up the Cloud Native Core on AWS on a single node to enable the deployment of AI applications via Helm charts from NGC.

- Ubuntu 18.04.3 LTS
- Docker CE 19.03.5 
- Kubernetes version 1.17.5
- Helm 3.1.0
- NVIDIA GPU Operator 1.1.7
  - NV containerized driver: 440.64.00
  - NV container toolkit: 1.0.2
  - NV K8S device plug-in: 1.0.0-beta6
  - Data Center GPU Manager (DCGM): 1.7.2

<h2>Table of Contents</h2>

- [Prerequisites](#Prerequisites)
- [AWS G4 Instance Setup](#AWS-G4-Instance-SetUp)
- [Installing Docker-CE](#Installing-Docker-CE)
- [Installing Kubernetes](#Installing-Kubernetes)
- [Installing Helm](#Installing-Helm)
- [Installing the GPU Operator](#Installing-the-GPU-Operator)
- [Validating the Installation](#Validating-the-Installation)

## Prerequisites
 
The following instructions are based on the assumption that you have an AWS account. If you don’t have an AWS account, please refer to the [Setup AWS account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/) webpage.  

Please note that the Cloud Native Core is only validated on AWS G4 systems with the default kernel (not HWE)


## AWS G4 Instance Setup
AWS G4 EC2 instances provide the latest generation NVIDIA T4 GPUs. To setup an CNC G4 instance via the AWS console web UI, please follow the below steps. 
First login to the AWS console and go to the EC2 management page and launch a new instance by clicking the launch instance button.

![AWS_Launch_Instance](screenshots/AWS_Launch_instance.png)

Step 1: Select the Ubuntu Server 18.04 LTS image with 64-bit (x86) which is available on Quick Start area.

![AWS_Choose_AMI](screenshots/AWS_Choose_AMI.png)

Step 2: Choose a  G4 instance. You can select any G4 instance type. (eg: g4dn.xlarge, g4dn.2xlarge etc.). For more information please refer [AWS G4 Instances](https://aws.amazon.com/blogs/aws/now-available-ec2-instances-g4-with-nvidia-t4-tensor-core-gpus/)

![AWS_Choose_Instance_Type](screenshots/AWS_Choose_Instance_type.png)

Step 3: In this step you will provide additional instance configuration details as per below.

![AWS_Configure_Instance_details](screenshots/AWS_Configure_Instance_details.png)

`NOTE:` This guide uses a default network configuration to showcase a working setup. Your setup might require a different configuration. Make sure to configure the network to align with your requirements so that the Cloud Native Core can connect to your sensor (RTSP camera). 
- Network: Use your default network or custom network configuration
- Subnet: Use the default subnet or custom subnet.

Step 4: Modify the storage to at least 25GB for the Cloud Native Core to work with the sample Intelligent Video Analytics Demo Application. Increase the storage to your requirements if you use a different application.

![AWS_Add_Storage](screenshots/AWS_Add_Storage.png)

Step 5: It is a good practice to add tags to your instance so that you can identify the purpose and details of each instance.

- For example, key as Name and it's value as CNC_Location_N.

![AWS_Add_Tags](screenshots/AWS_Add_Tags.png)

Step 6: For the security group settings, it is recommended that you create a security group with below rules.

- Type: SSH
- For testing with the DeepStream - Intelligent Video Analytics Demo application create a custom TCP rule that opens ports 30000-32767.

`NOTE:` Make sure to add all the ports that your custom application uses.

![AWS_Configure_Security_Group](screenshots/AWS_Configure_Security_Group.png)

Step 7: Review the instance configuration and click "Launch Instances", the key pair will pop up. Select the option “Choose an Existing Key Pair” if you already have a key pair. If not, select the option as “Create a New Key Pair”.

![AWS_Review_Instance_Config](screenshots/AWS_Review_Instance_Config.png)

Please wait at least 5 minutes to see the G4 node status checks passed. 

### AWS G4 Instance Access

Run the below command to ssh into your AWS Instance. Replace `yourkeypair.pem` and `<public-ip>` with you AWS Key Pair and your EC2 Public IP.

```
ssh -i yourkeypair.pem ubuntu@ec2-<public-ip>.us-west-1.compute.amazonaws.com
```

`NOTE:` You can get the EC2 Public IP from your AWS EC2 Management Console. 


## Installing Docker-CE
Update the apt package index:

```
$ sudo apt-get update
```

Install packages to allow apt to use a repository over HTTPS:

```
$ sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
```

Add Docker’s official GPG key:

```
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

Verify that you have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88, by searching for the last 8 characters of the fingerprint:
```
$ sudo apt-key fingerprint 0EBFCD88
    
pub   rsa4096 2017-02-22 [SCEA]
      9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
sub   rsa4096 2017-02-22 [S]
``` 

Use the following command to set up the stable repository:

```
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

### Install Docker Engine - Community
Update the apt package index:

```
$ sudo apt-get update
```

Install Docker Engine 19.03.5:

```
$ sudo apt-get install -y docker-ce=5:19.03.5~3-0~ubuntu-bionic docker-ce-cli=5:19.03.5~3-0~ubuntu-bionic containerd.io
```

Verify that Docker Engine - Community is installed correctly by running the hello-world image:

```
$ sudo docker run hello-world
```

More information on how to install Docker can be found at https://docs.docker.com/install/linux/docker-ce/ubuntu/. 

## Installing Kubernetes 

Make sure docker has been started and enabled before starting installation:

```
$ sudo systemctl start docker && sudo systemctl enable docker
```

Execute the following to install kubelet kubeadm and kubectl:

```
$ sudo apt-get update && sudo apt-get install -y apt-transport-https curl
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
$ sudo mkdir -p  /etc/apt/sources.list.d/
```

Create kubernetes.list

```
$ sudo nano /etc/apt/sources.list.d/kubernetes.list
```

Add the following lines in kubernetes.list and save the file:

```
deb https://apt.kubernetes.io/ kubernetes-xenial main
```

Now execute the below:

```
$ sudo apt-get update
$ sudo apt-get install -y -q kubelet=1.17.5-00 kubectl=1.17.5-00 kubeadm=1.17.5-00
$ sudo apt-mark hold kubelet kubeadm kubectl
```

### Initializing the Kubernetes cluster to run as master
Disable swap:
```
$ sudo swapoff -a
$ sudo nano /etc/fstab
```

Add a # before all the lines that start with /swap. # is a comment and the result should look something like this:

```
UUID=e879fda9-4306-4b5b-8512-bba726093f1d / ext4 defaults 0 0
UUID=DCD4-535C /boot/efi vfat defaults 0 0
#/swap.img       none    swap    sw      0       0
```

Execute the following command:

```
$ sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

The output will show you the commands that you can execute to deploy a pod network to the cluster as well as commands to join the cluster.

Following the instructions in the output, execute the commands as shown below:

```
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

With the following command you install a pod-network add-on to the control plane node. We are using calico as the pod-network add-on here:

```
$ kubectl apply -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml
```

You can run below commands to ensure all pods are up and running:

```
$ kubectl get pods --all-namespaces
```

Output:

```
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-65b8787765-bjc8h   1/1     Running   0          2m8s
kube-system   calico-node-c2tmk                          1/1     Running   0          2m8s
kube-system   coredns-5c98db65d4-d4kgh                   1/1     Running   0          9m8s
kube-system   coredns-5c98db65d4-h6x8m                   1/1     Running   0          9m8s
kube-system   etcd-#hostname                             1/1     Running   0          8m25s
kube-system   kube-apiserver-#hostname                   1/1     Running   0          8m7s
kube-system   kube-controller-manager-#hostname          1/1     Running   0          8m3s
kube-system   kube-proxy-6sh42                           1/1     Running   0          9m7s
kube-system   kube-scheduler-#hostname                   1/1     Running   0          8m26s
```

The get nodes command shows that the master node is up and ready:

```
$ kubectl get nodes
```

Output:

```
NAME       STATUS    ROLES    AGE   VERSION
#hostname   Ready    master   10m   v1.17.5
```

Since we are using a single node kubernetes cluster, the cluster will not be able to schedule pods on the control plane node by default. In order to schedule pods on the control plane node we have to remove the taint by executing the following command:

```
$ kubectl taint nodes --all node-role.kubernetes.io/master-
```

For more information, refer to [kubeadm installation guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

## Installing Helm 

Execute the following command to download Helm 3.1.0: 

```
$ sudo wget https://get.helm.sh/helm-v3.1.0-linux-amd64.tar.gz
$ sudo tar -zxvf helm-v3.1.0-linux-amd64.tar.gz
$ sudo mv linux-amd64/helm /usr/local/bin/helm
```

For more information about Helm, refer to https://github.com/helm/helm/releases and https://helm.sh/docs/using_helm/#installing-helm. 

## Installing the GPU Operator
Add the NVIDIA helm repo 

```
$ helm repo add nvidia https://nvidia.github.io/gpu-operator
```

Update the helm repo:

```
$ helm repo update
```

To install the GPU Operator for AWS G4 instance with Tesla T4

```
$ helm install --version 1.1.7 --devel nvidia/gpu-operator --wait --generate-name
```

### Validate the state of the GPU Operator:

Please note that the installation of the GPU Operator can take a couple minutes. How long you will have to wait will depend on your internet speed.

```
kubectl get pods --all-namespaces | grep -v kube-system
```

```
NAMESPACE                NAME                                                             READY   STATUS      RESTARTS   AGE

default                  gpu-operator-1590097431-node-feature-discovery-master-76578jwwt   1/1     Running     0          5m2s
default                  gpu-operator-1590097431-node-feature-discovery-worker-pv5nf       1/1     Running     0          5m2s
default                  gpu-operator-74c97448d9-n75g8                                     1/1     Running     1          5m2s
gpu-operator-resources   nvidia-container-toolkit-daemonset-pwhfr                          1/1     Running     0          4m58s
gpu-operator-resources   nvidia-dcgm-exporter-bdzrz                                        1/1     Running     0          4m57s
gpu-operator-resources   nvidia-device-plugin-daemonset-zmjhn                              1/1     Running     0          4m57s
gpu-operator-resources   nvidia-device-plugin-validation                                   0/1     Completed   0          4m57s
gpu-operator-resources   nvidia-driver-daemonset-7b66v                                     1/1     Running     0          4m57s
gpu-operator-resources   nvidia-driver-validation                                          0/1     Completed   0          4m57s

```

Please refer to https://github.com/NVIDIA/gpu-operator for more information.

## Validating the Installation

The GPU Operator validates the stack through the nvidia-device-plugin-validation pod and the nvidia-driver-validation pod. If both completed successfully (see output from kubectl get pods --all-namespaces | grep -v kube-system), the Cloud Native Core works as expected. 
There are two ways to validate the Cloud Native Core manually: 
1. Validate the Cloud Native Core with nvidia-smi and cuda sample
2. Validate the Cloud Native Core with an Application


### Validate the Cloud Native Core with nvidia-smi and cuda sample
This section provides two examples of how to validate that the GPU is usable from within a pod.

#### Example 1: nvidia-smi

Execute the follwoing:

```
$ kubectl run nvidia-smi --rm -t -i --restart=Never --image=nvidia/cuda --limits=nvidia.com/gpu=1 -- nvidia-smi
```

Output:

``` 
Mon Aug 20 17:51:27 2020
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 440.64.00    Driver Version: 440.64.00    CUDA Version: 11.0     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  Tesla T4            On   | 00000000:00:1E.0 Off |                    0 |
| N/A   30C    P8    10W /  70W |      0MiB / 15109MiB |      1%      Default |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
pod "nvidia-smi" deleted
```

#### Example 2: CUDA-Vector-Add

Create a pod yaml file:

```
$ sudo nano cuda-samples.yaml
```

Add the below and save it as cuda-samples.yaml:

```
apiVersion: v1
kind: Pod
metadata:
  name: cuda-vector-add
spec:
  restartPolicy: OnFailure
  containers:
    - name: cuda-vector-add
      image: "k8s.gcr.io/cuda-vector-add:v0.1"
```

Run the below command to create a sample GPU pod:

```
$ sudo kubectl apply -f cuda-samples.yaml
```

Check if the cuda-samples pod was created:

```
$ kubectl get pods
``` 

The CNC stack works as expected if the get pods command shows the pod status as completed.

### Validate the Cloud Native Core with an Application

You can validate the Cloud Native Core and its connectivity to the remote sensor by running an application that is connected to the sensor. The DeepStream - Intelligent Video Analytics (IVA) Demo application can be used for that purpose. It delivers real-time AI based video and image understanding and multi-sensor processing on GPUs. It will use the Deepstream SDKo analyze deep learning networks. For more information, please refer to the [Helm Chart](https://ngc.nvidia.com/catalog/helm-charts/nvidia:video-analytics-demo)

There are two ways to configure the DeepStream - Intelligent Video Analytics Demo Application on your Cloud Native Core

- Using a camera
- Using the integrated video file (no camera)

#### Using a camera

##### Prerequisites: 
- RTSP Camera stream

  `NOTE:` RTSP Camera should be accessible from the AWS G4 instance. If your RTSP stream is within AWS, you can go through the links below how to connect your Private network. 
  - https://aws.amazon.com/premiumsupport/knowledge-center/connect-vpc/
  - https://aws.amazon.com/premiumsupport/knowledge-center/create-connection-vpc/

Go through the below steps to install the demo application. 
```
1. helm fetch https://helm.ngc.nvidia.com/nvidia/charts/video-analytics-demo-0.1.5.tgz --untar

2. cd into the folder video-analytics-demo and update the file values.yaml

3. Go to the section Cameras in the values.yaml file and add the address of your IP camera. Read the comments section on how it can be added. Single or multiple cameras can be added as shown below

cameras:
 camera1: rtsp://XXXX
```

Run the following command to deploy the demo application:
```
helm install video-analytics-demo --name-template iva
```

Once the helm chart is deployed, access the application with the VLC player. See the instructions below. 

#### Using the integrated video file (no camera)

If you don’t have a camera input, please run the below commands to use the default video which is already integrated in the application. 

```
$ helm fetch https://helm.ngc.nvidia.com/nvidia/charts/video-analytics-demo-0.1.5.tgz

$ helm install video-analytics-demo-0.1.5 --name-template iva
```

Once the helm chart is deployed, Access the Application with VLC player as per below instructions. 
For more information about Demo application, please refer https://ngc.nvidia.com/catalog/helm-charts/nvidia:video-analytics-demo

#### Access from WebUI

View the video stream from Web Browser by using below url
```
 http://<ec2-public-ip>:31115/WebRTCApp/play.html?name=videoanalytics
 ```
`NOTE:` The EC2 Public IP can be viewed from AWS EC2 console. 

#### Access from VLC

Download VLC Player from: https://www.videolan.org/vlc/ on the machine where you intend to view the video stream.

View the video stream in VLC by navigating to Media > Open Network Stream > Entering the following URL

```
rtsp://<ec2-public-ip>:31113/ds-test
```

`NOTE:` The EC2 Public IP can be viewed from AWS EC2 console. 

You will now see the video output like below with the AI model detecting objects.

![Deepstream_Video](screenshots/Deepstream.png)

`NOTE:` Video stream in VLC will change if you provide an input RTSP camera.
## Cleanup

To remove your AWS instance, login to the AWS console and go to the EC2 management page and select your EC2 instance and select Actions >> Select Instance State and then click  Terminate.
