FROM jupyter/scipy-notebook

# Enable `conda activate`
RUN conda init bash

COPY conda-env-tf2-gpu-py37.yml conda-env-tf2-gpu-py37.yml
RUN conda env create --quiet --file conda-env-tf2-gpu-py37.yml && conda clean -all --yes
