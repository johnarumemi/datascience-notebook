# This docker image is for my personal use on machine learning and finance related tasks
ARG NB_IMAGE_BASE=jupyter/base-notebook
ARG NB_IMAGE_TAG=latest 

FROM $NB_IMAGE_BASE:$NB_IMAGE_TAG
LABEL maintainer="John Arumemi <john.arumemi@gmail.com>"

# Switch to root
USER root

# Install all OS dependencies for fully functional notebook server
RUN apt-get update -y && apt-get install gnupg2 -yq --no-install-recommends && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    sudo apt-get update -y && \
    apt-get install -yq --no-install-recommends \
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
    # PostgreSQL Client
    postgresql-client-12 \
    # ---- nbconvert dependencies ----
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-generic-recommended \
    # Optional dependency
    texlive-fonts-extra \
    # ----
    iputils-ping \
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
    # --- Scientific Libraries
    numpy \
    cython \
    scipy \
    statsmodels \
    pandas \
    numba \
    # --- Machine Learning ---
    scikit-learn \
    nltk \
    tensorflow \
    keras \
    xgboost \
    # -- Plotting Libraries ---
    matplotlib \
    seaborn \
    plotly=4.6.0 \
    python-graphviz \
    # --- General ---
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

# Jupyterlab extensions
# --- Editors
# Vim
# Jupyter/Ipython Widgets
# Table of Contents
# --- Viewers & Renderers
# plotly jupyterlab renderer support
# plotly jupyterlab FigureWidget supprt
ENV JUPYTER_LAB_EXTENSIONS="\
    # --- Editors ---
    @axlair/jupyterlab_vim \
    @jupyter-widgets/jupyterlab-manager \
    @jupyterlab/toc \
    # --- Viewers/Renderers ---
    jupyterlab-plotly@4.6.0 \
    plotlywidget@4.6.0 \
"


# Install Jupyterlab Extensions
# L1 : Avoid "JavaScript heap out of memory" errors during extension installation
# L2 : Install Extentions with --no-build
# L3 : Build extensions with minimize set to False (this should be a production build)
# END: Unset NODE_OPTIONS environment variable
# END: Fix Permission; run this script after every install if a directory needs to be writiable by NB_GID
RUN export NODE_OPTIONS=--max-old-space-size=4096 && \
    jupyter labextension install $JUPYTER_LAB_EXTENSIONS --no-build && \
    jupyter lab build --minimize=False && \
    jupyter lab clean && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    unset NODE_OPTIONS && \
    fix-permissions $HOME && \
    fix-permissions $CONDA_DIR/share/jupyter && \
    echo "COMPLETED ALL INSTALLS" 

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
