FROM nvidia/cuda:11.3.0-cudnn8-devel-ubuntu20.04

WORKDIR /workspace

# Install Miniconda3:
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN apt-get update
RUN apt-get install -y wget && rm -rf /var/lib/apt/lists/*
RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh 
RUN conda --version

# Install git:
RUN apt-get -y update
RUN apt-get -y install git

# Create the environment:
COPY ldm ./ldm
COPY setup.py .
COPY environment.yaml .
RUN conda env create -f environment.yaml

# Make RUN commands use the new environment:
SHELL ["conda", "run", "-n", "ldm", "/bin/bash", "-c"]

# Demonstrate the environment is activated:
RUN echo "Make sure ldm is installed:"
RUN python -c "import ldm"

# Install jupyterlab for experiment usage:
RUN pip install jupyterlab

RUN echo -e "#! /bin/bash\n\n# script to activate the conda environment" > ~/.bashrc \
&& conda init bash \
&& echo -e "\nconda activate ldm" >> ~/.bashrc \
&& echo "echo \"LDM environment activated\"" >>  ~/.bashrc \
&& conda clean -a

# environment variables
ENV BASH_ENV ~/.bashrc

# Run `docker build -t stable-diffusion .` to build a docker image.
# Run a container by `docker run --gpus all -it --rm -p 8888:8888 stable-diffusion`.
# Then, you can run `jupyter lab --allow-root --ip 0.0.0.0` in the container shell.
# Open `127.0.0.1:8888` in web browser to start your experiment.
