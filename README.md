# deeplearning-jupyterhub-docker

Docker file for deep learning and JupyterHub

## Prerequisites

### docker with nvidia support

Follow the instructions from the TensorFlow project on configuring Docker with GPU support.

- https://www.tensorflow.org/install/docker#tensorflow_docker_requirements

## Building and running

Build:
``` 
$ docker build -t deeplearning-jupyterhub-docker:latest -f Dockerfile .
```

Run:
``` 
$ docker run --gpus all -it -p 8888:8888 -p 6006:6006 -v $(realpath ~/workspace):/home/jovyan/workspace deeplearning-jupyterhub-docker:latest bash
```

## Running remotely

Enable ssh port forwarding

```
$ ssh -L 8888:localhost:8888 username@domain
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
