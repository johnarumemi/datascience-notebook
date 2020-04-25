# This docker image is for my personal use on machine learning and finance related tasks
ARG NB_IMAGE_BASE=jupyter/base-notebook
ARG NB_IMAGE_TAG=latest 

FROM $NB_IMAGE_BASE:$NB_IMAGE_TAG
LABEL maintainer="John Arumemi <john.arumemi@gmail.com>"

# Switch to root
USER root

# Install all OS dependencies for fully functional notebook server
RUN apt-get update && apt-get install -yq --no-install-recommends \
    build-essential \
    emacs \
    git \
    inkscape \
    jed \
    libsm6 \
    libxext-dev \
    libxrender1 \
    lmodern \
    netcat \
    python-dev \
    # ---- nbconvert dependencies ----
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-generic-recommended \
    # Optional dependency
    texlive-fonts-extra \
    # ----
    tzdata \
    unzip \
    nano \
    vim \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# PYTHON DATA SCIENCE PACKAGES
# Scientific Libraries
#   * numpy: support for large, multi-dimensional arrays and matrices
#   * scipy: library used for scientific computing and technical computing
#   * statsmodel:
#   * pandas: library providing high-performance, easy-to-use data structures and data analysis tools
#   * numba:
#
# Machine Learning
#   * scikit-learn: machine learning library integrates with NumPy and SciPy
#   * tensorflow
#   * keras
#   * xgboost
#   * nltk: suite of libraries and programs for symbolic and statistical natural language processing for English
#   * mglearn (pip)
#
# Plotting
#   * matplotlib: plotting library for Python and its numerical mathematics extension NumPy.
#   * seaborn   :
#   * python-graphviz: 
#   * plotly:
#   * chart_studio (pip)
#   * cufflinks (pip)
#
# Quant Tools
#   * iexfinance (pip)
#
# General  
#   * psycopg2 : api for interacting with PostgreSQL database
#   * cython   :
#   * xlrd     :
#   * openpyxl :
#   * psutil   : required by plotly to enable certain functionality.
#   * pytables : hdf5 file support
#
ENV CONDA_PYTHON_PACKAGES="\
    numpy \
    cython \
    scipy \
    statsmodels \
    pandas \
    numba \
    scikit-learn \
    nltk \
    tensorflow \
    keras \
    xgboost \
    matplotlib \
    seaborn \
    plotly \
    python-graphviz \
    psycopg2 \
    pytables \
    openpyxl \
    ipywidgets \
    xlrd \
"

ENV PIP_PYTHON_PACKAGES="\
    mglearn \
    iexfinance \
    cufflinks \
    chart_studio \
    psutil \
"

# Install Python Packages
RUN conda update --yes -n base conda &&  > /dev/null && \
    conda config --prepend channels plotly > /dev/null && \
    conda config --prepend channels conda-forge > /dev/null && \
    conda install --yes --no-channel-priority $CONDA_PYTHON_PACKAGES > /dev/null && \
    pip install --no-cache $PIP_PYTHON_PACKAGES > /dev/null && \
    conda clean --all --quiet --yes > /dev/null

# Install jupyterlab extensions for plotly support
# L1 : Avoid "JavaScript heap out of memory" errors during extension installation
# L2 : Jupyterlab Vim
# L3 : plotly jupyterlab renderer support
# L4 : plotly jupyterlab widgets extension (FigureWidget Support)
# L5 : Jupyter widgets extension
# L6 : Table of Contents
# L7 : Build extensions (must be done to activate extensions since --no-build is used below)
# END: Unset NODE_OPTIONS environment variable
RUN export NODE_OPTIONS=--max-old-space-size=4096 && \
    jupyter labextension install @axlair/jupyterlab_vim --no-build && \
    jupyter labextension install jupyterlab-plotly@4.6.0 --no-build && \
    jupyter labextension install plotlywidget@4.6.0 --no-build && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
    jupyter labextension install @jupyterlab/toc --no-build && \
    jupyter lab build && \
    jupyter lab clean && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    unset NODE_OPTIONS

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
