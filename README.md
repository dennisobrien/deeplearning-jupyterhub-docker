# deeplearning-jupyterhub-docker

Docker file for deep learning and JupyterHub

## Prerequisites

### nvidia-docker

In order to make the GPU available to the docker container, install
the CLI provided by nvidia.

- https://github.com/NVIDIA/nvidia-docker

### nvidia drivers

This does require that you have nvidia gpu driver and cuda driver installed.

- http://www.linuxandubuntu.com/home/how-to-install-latest-nvidia-drivers-in-linux
- http://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html

## Building and running

Build:
``` 
$ docker build -t deeplearning-jupyterhub-docker:latest -f Dockerfile .
```

Run
``` 
$ nvidia-docker run -it -p 8888:8888 -p 6006:6006 -v ~/workspace:/root/workspace deeplearning-jupyterhub-docker:latest bash
```

## Updating conda environments

Conda environments are created from a yaml file.  It is easiest to modify
the environment from within the docker image.

Update the environment file when a dependency has been added or modified.
```
# 
```

## Resources

- https://github.com/floydhub/dl-docker
