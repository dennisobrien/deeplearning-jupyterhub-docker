FROM nvidia/cuda:8.0-cudnn7-devel-ubuntu16.04

# Based on the work of many others
# https://github.com/floydhub/dl-docker/blob/master/Dockerfile.gpu

MAINTAINER Dennis O'Brien <dennis@dennisobrien.net>

ARG THEANO_VERSION=rel-0.8.2
ARG TENSORFLOW_VERSION=0.12.1
ARG TENSORFLOW_ARCH=gpu
ARG KERAS_VERSION=1.2.0
ARG LASAGNE_VERSION=v0.1
ARG TORCH_VERSION=latest
ARG CAFFE_VERSION=master

RUN echo -e "\n**********************\nNVIDIA Driver Version\n**********************\n" && \
    cat /proc/driver/nvidia/version && \
    echo -e "\n**********************\nCUDA Version\n**********************\n" && \
    nvcc -V && \
    echo -e "\n\nBuilding your Deep Learning Docker Image...\n"

# Install some dependencies
RUN apt-get update && apt-get install -y \
        ant \
        bc \
        build-essential \
        cmake \
        curl \
        default-jdk \
        doxygen \
        g++ \
        gfortran \
        git \
        libavcodec-dev \
        libavformat-dev \
        libcupti-dev \
        libffi-dev \
        libfreetype6-dev \
        libhdf5-dev \
        libjpeg-dev \
        liblcms2-dev \
        libopenblas-dev \
        liblapack-dev \
        libopenjpeg5 \
        libpng12-dev \
        libssl-dev \
        libtiff5-dev \
        libvtk6-dev \
        libwebp-dev \
        libzmq3-dev \
        libjpeg-dev \
        libwebp-dev \
        libpng-dev \
        libtiff5-dev \
        libjasper-dev \
        libopencore-amrnb-dev \
        libopencore-amrwb-dev \
        libv4l-dev \
        libxine2-dev \
        libtbb-dev \
        libeigen3-dev \
        libopenexr-dev \
        libgdal-dev \
        libdc1394-22-dev \
        libswscale-dev \
        libtheora-dev \
        libvorbis-dev \
        libxvidcore-dev \
        libx264-dev \
        nano \
        nodejs-legacy \
        npm \
        pkg-config \
        python-dev \
        python-tk \
        python-numpy \
        python3-dev \
        python3-tk \
        python3-numpy \
        qt5-default \
        software-properties-common \
        unzip \
        vim \
        wget \
        zlib1g-dev \
        zlib1g-dev \
        yasm \
        && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
# Link BLAS library to use OpenBLAS using the alternatives mechanism (https://www.scipy.org/scipylib/building/linux.html#debian-ubuntu)
    update-alternatives --set libblas.so.3 /usr/lib/openblas-base/libblas.so.3

# Install miniconda
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --no-verbose -O ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-4.3.21-Linux-x86_64.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

ENV PATH /opt/conda/bin:$PATH
COPY conda-env-py3.yml conda-env-py3.yml
RUN conda env create --file conda-env-py3.yml \
    && conda clean -a
ENV PATH /opt/conda/envs/py3/bin:$PATH


## Install pip
#RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
#    python get-pip.py && \
#    rm get-pip.py
#
## Add SNI support to Python
#RUN pip --no-cache-dir install \
#        pyopenssl \
#        ndg-httpsclient \
#        pyasn1
#
## Install useful Python packages using apt-get to avoid version incompatibilities with Tensorflow binary
## especially numpy, scipy, skimage and sklearn (see https://github.com/tensorflow/tensorflow/issues/2034)
#RUN apt-get update && apt-get install -y \
#        python-numpy \
#        python-scipy \
#        python-nose \
#        python-h5py \
#        python-skimage \
#        python-matplotlib \
#        python-pandas \
#        python-sklearn \
#        python-sympy \
#        && \
#    apt-get clean && \
#    apt-get autoremove && \
#    rm -rf /var/lib/apt/lists/*
#
## Install other useful Python packages using pip
#RUN pip --no-cache-dir install --upgrade ipython && \
#    pip --no-cache-dir install \
#        Cython \
#        ipykernel \
#        jupyter \
#        path.py \
#        Pillow \
#        pygments \
#        six \
#        sphinx \
#        wheel \
#        zmq \
#        && \
#    python -m ipykernel.kernelspec
#
#
## Install TensorFlow
RUN pip install --ignore-installed --upgrade \
    https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.3.0-cp36-cp36m-linux_x86_64.whl

## Install dependencies for Caffe
#RUN apt-get update && apt-get install -y \
#        libboost-all-dev \
#        libgflags-dev \
#        libgoogle-glog-dev \
#        libhdf5-serial-dev \
#        libleveldb-dev \
#        liblmdb-dev \
#        libopencv-dev \
#        libprotobuf-dev \
#        libsnappy-dev \
#        protobuf-compiler \
#        && \
#    apt-get clean && \
#    apt-get autoremove && \
#    rm -rf /var/lib/apt/lists/*
#
## Install Caffe
#RUN git clone -b ${CAFFE_VERSION} --depth 1 https://github.com/BVLC/caffe.git /root/caffe && \
#    cd /root/caffe && \
#    cat python/requirements.txt | xargs -n1 pip install && \
#    mkdir build && cd build && \
#    cmake -DUSE_CUDNN=1 -DBLAS=Open .. && \
#    make -j"$(nproc)" all && \
#    make install
#
## Set up Caffe environment variables
#ENV CAFFE_ROOT=/root/caffe
#ENV PYCAFFE_ROOT=$CAFFE_ROOT/python
#ENV PYTHONPATH=$PYCAFFE_ROOT:$PYTHONPATH \
#    PATH=$CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
#
#RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig
#
#
## Install Theano and set up Theano config (.theanorc) for CUDA and OpenBLAS
#RUN pip --no-cache-dir install git+git://github.com/Theano/Theano.git@${THEANO_VERSION} && \
#    \
#    echo "[global]\ndevice=gpu\nfloatX=float32\noptimizer_including=cudnn\nmode=FAST_RUN \
#        \n[lib]\ncnmem=0.95 \
#        \n[nvcc]\nfastmath=True \
#        \n[blas]\nldflag = -L/usr/lib/openblas-base -lopenblas \
#        \n[DebugMode]\ncheck_finite=1" \
#    > /root/.theanorc
#
#
## Install Keras
#RUN pip --no-cache-dir install git+git://github.com/fchollet/keras.git@${KERAS_VERSION}
#
#
## Install Lasagne
#RUN pip --no-cache-dir install git+git://github.com/Lasagne/Lasagne.git@${LASAGNE_VERSION}
#
#
## Install Torch
#RUN git clone https://github.com/torch/distro.git /root/torch --recursive && \
#    cd /root/torch && \
#    bash install-deps && \
#    yes no | ./install.sh
#
## Export the LUA evironment variables manually
#ENV LUA_PATH='/root/.luarocks/share/lua/5.1/?.lua;/root/.luarocks/share/lua/5.1/?/init.lua;/root/torch/install/share/lua/5.1/?.lua;/root/torch/install/share/lua/5.1/?/init.lua;./?.lua;/root/torch/install/share/luajit-2.1.0-beta1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua' \
#    LUA_CPATH='/root/.luarocks/lib/lua/5.1/?.so;/root/torch/install/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so' \
#    PATH=/root/torch/install/bin:$PATH \
#    LD_LIBRARY_PATH=/root/torch/install/lib:$LD_LIBRARY_PATH \
#    DYLD_LIBRARY_PATH=/root/torch/install/lib:$DYLD_LIBRARY_PATH
#ENV LUA_CPATH='/root/torch/install/lib/?.so;'$LUA_CPATH
#
## Install the latest versions of nn, cutorch, cunn, cuDNN bindings and iTorch
#RUN luarocks install nn && \
#    luarocks install cutorch && \
#    luarocks install cunn && \
#    luarocks install loadcaffe && \
#    \
#    cd /root && git clone https://github.com/soumith/cudnn.torch.git && cd cudnn.torch && \
#    git checkout R4 && \
#    luarocks make && \
#    \
#    cd /root && git clone https://github.com/facebook/iTorch.git && \
#    cd iTorch && \
#    luarocks make
#
## Install OpenCV
#RUN git clone --depth 1 https://github.com/opencv/opencv.git /root/opencv && \
#    cd /root/opencv && \
#    mkdir build && \
#    cd build && \
#    cmake -DWITH_QT=ON -DWITH_OPENGL=ON -DFORCE_VTK=ON -DWITH_TBB=ON -DWITH_GDAL=ON -DWITH_XINE=ON -DBUILD_EXAMPLES=ON .. && \
#    make -j"$(nproc)"  && \
#    make install && \
#    ldconfig && \
#    echo 'ln /dev/null /dev/raw1394' >> ~/.bashrc

# Set up notebook config
#COPY jupyter_notebook_config.py /root/.jupyter/
ONBUILD ADD jupyterhub_config.py /srv/jupyterhub/jupyterhub_config.py

# Expose Ports for TensorBoard (6006), Ipython (8888)
EXPOSE 6006 8888

RUN mkdir -p /srv/jupyterhub/
WORKDIR /srv/jupyterhub/
CMD ["jupyterhub", "-f", "/srv/jupyterhub/jupyterhub_config.py"]