# Docker GPU Environment

This repository provides a Docker-based environment for machine learning and robotics projects. The generated image is approximately 25Gb.

## Dockerfile Contents

Base Image: 
- Ubuntu 20.04
- Python: 3.8
- CUDA: 12.1.0
- PyTorch: 2.1.2

Includes requirements for the following repositories, cloned from my forks which contain several fixes:
- [HybrIK](https://github.com/gursoyege/HybrIK)
- [HybrIK-TensorRT](https://github.com/gursoyege/HybrIK-TensorRT)
- [human2humanoid](https://github.com/gursoyege/human2humanoid)

## Building the Docker Image

To build the Docker image, run the following command in the repository directory:

```bash
docker build -t <your_image_name> .
```
Replace <your_image_name> with your desired image name.

## Running the Container

First, make sure to install `nvidia-container-toolkit` to your HOST machine.

```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg && \
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list && \
sudo apt-get update && \
sudo apt-get install -y nvidia-container-toolkit
```

The provided `run.sh` script helps to run the container with GPU support and X11 forwarding. It accepts the following arguments:


- -i or --image: Specify the Docker image name.
- -n or --name: Specify the container name.
- -t or --temp: (Optional) Run the container in temporary mode (automatically removed after exit).

Example usage:

```bash
chmod +x run.sh
./run.sh -i <your_image_name> -n <your_container_name> -t
```
This script will:

- Set the display environment variable.
- Temporarily allow X11 access with xhost.
- Run the container with GPU support and the necessary mounts and privileges.
- Revoke the temporary X11 access after the container exits.
