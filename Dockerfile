FROM ubuntu:18.04

LABEL maintainer="Hayath"
LABEL version="1.0"
LABEL description="The Rust In Its Full Glory"

ARG USERNAME
ARG UID
ARG PROJECT_PWD

RUN apt-get remove git -y && apt-get update -y

# FF Specidif
RUN apt-get install awscli libpq-dev nodejs npm -y

# Install base utilities
RUN apt-get update && \
    apt-get install -y build-essential && \
    apt-get install -y wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install miniconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
     /bin/bash ~/miniconda.sh -b -p /opt/conda

# Put conda in path so we can use conda activate
ENV PATH=$CONDA_DIR/bin:$PATH

#########################################
RUN useradd -ms /bin/bash $USERNAME -u $UID; exit 0
RUN usermod -a -G sudo $USERNAME; exit 0
WORKDIR "$PROJECT_PWD"
RUN apt-get autoremove -y

RUN npm install -g serverless --quiet
RUN npm install serverless-python-requirements serverless-secrets-plugin serverless-prune-plugin serverless-domain-manager serverless-api-compression --save-dev --quiet
RUN npm install -g newman --quiet
# -----------------

RUN conda update -n base -c defaults conda

EXPOSE 8000
USER $USERNAME
ENV USER=$USERNAME
ENV PATH=$PATH:/home/$USERNAME/.local/bin/

RUN conda init; exit 0
RUN conda create -n py36 python=3.6 -y
RUN conda install suds-jurko==0.6 -n py36 -y
RUN echo "conda activate py36" >> /home/$USERNAME/.bashrc
