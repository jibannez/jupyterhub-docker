# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG OWNER=jupyter
ARG BASE_CONTAINER=$OWNER/datascience-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install the full octave environment (around 3GB)
USER root
RUN apt-get update --yes &&\
    apt-get install --yes --no-install-recommends gnuplot octave octave-* fonts-freefont-otf && \
    apt-get clean
    #apt-get install --yes --no-install-recommends octave octave-statistics octave-signal octave-optim octave-nlopt octave-general octave-geometry octave-image octave-io octave-linear-algebra gnuplot fonts-freefont-otf

# Install rise for notebooks and for labs, and a few additional python packages
USER ${NB_UID}
RUN pip install --no-cache-dir \
    dockerspawner \
    jupyterhub-nativeauthenticator \
    RISE \
    nbslide \
    jupyterlab_rise \
    roboticstoolbox-python \
    pingouin \
    plotly \
    plotly-geo \
    octave-kernel \
    kaleido && \
    export OCTAVE_EXECUTABLE=$(which octave) && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}" 

# Additional R packages
RUN mamba install --quiet --yes \
    'r-lme4' \
    'r-ez' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Install Tensorflow with pip
# DISABLED FOR NOW AS IT DOES NOT WORK [TF SEGFAULTS ON IMPORT]!!
# hadolint ignore=DL3013
#RUN pip install --no-cache-dir tensorflow-cpu keras && \
   # torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu116 && \ #FOR CUDA 11.6
   # fix-permissions "${CONDA_DIR}" && \
   # fix-permissions "/home/${NB_USER}"

WORKDIR "${HOME}"

