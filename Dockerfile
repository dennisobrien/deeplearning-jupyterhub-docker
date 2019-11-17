FROM jupyter/scipy-notebook

# Enable `conda activate`
RUN conda init bash

# Configure some custom JupyterLab extensions
conda install -c bokeh jupyter_bokeh
jupyter labextension install @jupyter-widgets/jupyterlab-manager
jupyter labextension install @bokeh/jupyter_bokeh

COPY conda-env-tf2.0-gpu-py3.7.yml conda-env-tf2.0-gpu-py3.7.yml
RUN conda env create --quiet --file conda-env-tf2.0-gpu-py3.7.yml && conda clean -all --yes

