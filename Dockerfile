FROM jupyter/datascience-notebook

USER root

# Install all OS dependencies for fully functional notebook server
RUN apt-get update --fix-missing && \
    apt-get -y install \
    build-essential \
    cmake \
    curl \
    htop \
    libfreetype6-dev \
    libpng12-dev \
    libzmq3-dev \
    nano \
    openssh-client \
    pkg-config \
    python \
    python-dev \
    rsync \
    software-properties-common \
    unzip \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#
# CUDA and CUDnn
# This section is a copy/paste from two nvidia docker images.
#
# https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/8.0/runtime/Dockerfile
RUN NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 && \
    NVIDIA_GPGKEY_FPR=ae09fe4bbd223a84b2ccfce3f60f4b3d7fa2af80 && \
    apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub && \
    apt-key adv --export --no-emit-version -a $NVIDIA_GPGKEY_FPR | tail -n +5 > cudasign.pub && \
    echo "$NVIDIA_GPGKEY_SUM  cudasign.pub" | sha256sum -c --strict - && rm cudasign.pub && \
    echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list
ENV CUDA_VERSION 8.0.61
ENV CUDA_PKG_VERSION 8-0=$CUDA_VERSION-1
#RUN apt-get update && apt-get install -y --no-install-recommends \
#        cuda-nvrtc-$CUDA_PKG_VERSION \
#        cuda-nvgraph-$CUDA_PKG_VERSION \
#        cuda-cusolver-$CUDA_PKG_VERSION \
#        cuda-cublas-8-0=8.0.61.2-1 \
#        cuda-cufft-$CUDA_PKG_VERSION \
#        cuda-curand-$CUDA_PKG_VERSION \
#        cuda-cusparse-$CUDA_PKG_VERSION \
#        cuda-npp-$CUDA_PKG_VERSION \
#        cuda-cudart-$CUDA_PKG_VERSION && \
#    ln -s cuda-8.0 /usr/local/cuda && \
#    rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y --no-install-recommends cuda-$CUDA_PKG_VERSION && \
    ln -s cuda-8.0 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*
# nvidia-docker 1.0
LABEL com.nvidia.volumes.needed="nvidia_driver"
LABEL com.nvidia.cuda.version="${CUDA_VERSION}"
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=8.0"

# https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/8.0/runtime/cudnn6/Dockerfile
RUN echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list
ENV CUDNN_VERSION 6.0.21
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"
RUN apt-get update && apt-get install -y --no-install-recommends \
            libcudnn6=$CUDNN_VERSION-1+cuda8.0 && \
    rm -rf /var/lib/apt/lists/*

ENV CUDA_BIN_PATH=/usr/local/cuda
ENV CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-8.0


USER $NB_USER

# configure the root conda environment
RUN conda config --add channels conda-forge
RUN conda install --quiet --yes \
    jupyter_contrib_nbextensions==0.3.3 \
    nb_conda==2.2.1 \
    nbdime==0.3.0 \
    pyodbc==4.0.17 \
    sqlparse==0.2.3 \
    xlrd==1.0.0 \
    && conda clean -a
RUN pip install jupyterhub==0.8.0.b4

# configure ndbime to work with git for handling notebook diffs and merges nicely
RUN nbdime config-git --enable --global

# configure some nbextensions
RUN jupyter nbextension enable execute_time/ExecuteTime
RUN jupyter nbextension enable toc2/main
RUN jupyter labextension install jupyterlab_bokeh
RUN jupyter labextension install @jupyterlab/vega2-extension
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager

COPY conda-env-py36.yml conda-env-py36.yml
RUN conda env create --quiet --file conda-env-py36.yml && conda clean -all --yes

# build xgboost with gpu support and install in conda-env-py36-gpu
#RUN git clone --recursive https://github.com/dmlc/xgboost /tmp/xgboost && \
#    cd /tmp/xgboost && git checkout v0.7 && \
#    mkdir build && cd build && \
#    cmake .. -DUSE_CUDA=ON -DCUDA_TOOLKIT_ROOT_DIR=$CUDA_TOOLKIT_ROOT_DIR && \
#    make -j && \
#    cd ../python-package && /opt/conda/envs/py36-gpu/bin/python setup.py install

# And finally, back to running as the user
USER $NB_USER

ENV JOBLIB_TEMP_FOLDER /tmp/joblib_cache

# Open additional port for TensorBoard
EXPOSE 6006