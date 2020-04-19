FROM jupyter/scipy-notebook

# Enable `conda activate`
RUN conda init bash

# Configure some custom JupyterLab extensions
RUN conda install -c bokeh jupyter_bokeh
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager
RUN jupyter labextension install @bokeh/jupyter_bokeh

COPY conda-env-tf2-gpu-py37.yml conda-env-tf2-gpu-py37.yml
RUN conda env create --quiet --file conda-env-tf2-gpu-py37.yml && conda clean -all --yes
