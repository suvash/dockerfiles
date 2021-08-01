FROM nvidia/cuda:11.1.1-base-ubuntu20.04

RUN set -exu \
    \
    && apt-get update \
    && apt-get install --yes --no-install-recommends \
               bzip2 \
               ca-certificates \
               wget \
               curl \
               jq \
               sudo \
               gosu \
    && apt-get clean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/apt/lists/* \
    && gosu nobody true

ARG USER_GROUP_NAME="karta"
ARG USER_SHELL="/bin/bash"
ARG UID_GID="9001"
ARG WORKDIR="/workspace"
ARG CONDA_BASE_DIR="/opt"
ARG CONDAENV="py37-pytorch19"

RUN useradd --user-group --create-home --shell "$USER_SHELL" --uid "$UID_GID" "$USER_GROUP_NAME" \
    && usermod --append --groups sudo "$USER_GROUP_NAME" \
    && passwd --delete "$USER_GROUP_NAME" \
    && mkdir -p "$WORKDIR" "$CONDA_BASE_DIR" \
    && chown -R "$USER_GROUP_NAME:$USER_GROUP_NAME" "$WORKDIR" "$CONDA_BASE_DIR"

USER "$USER_GROUP_NAME"

# HACK : let all users use /home/$USER_GROUP_NAME as their home directory
ENV HOME="/home/$USER_GROUP_NAME"
RUN chmod 777 "/home/$USER_GROUP_NAME"

ARG CONDA_VERSION="py37_4.10.3"
ARG CONDA_SHA256SUM="a1a7285dea0edc430b2bc7951d89bb30a2a1b32026d2a7b02aacaaa95cf69c7c"

ENV CONDA_AUTO_UPDATE_CONDA=false \
    CONDADIR="$CONDA_BASE_DIR/conda" \
    CONDAENV="$CONDAENV" \
    PATH="$CONDA_BASE_DIR/conda/bin:$PATH"

RUN set -exu \
    \
    && MINICONDA_URL="https://repo.continuum.io/miniconda/Miniconda3-$CONDA_VERSION-Linux-x86_64.sh" \
    && wget "$MINICONDA_URL" -O /tmp/miniconda.sh \
    && echo "$CONDA_SHA256SUM /tmp/miniconda.sh" > /tmp/shashum.txt \
    && sha256sum --check --status /tmp/shashum.txt \
    && sh /tmp/miniconda.sh -b -p "$CONDADIR" \
    && rm /tmp/miniconda.sh /tmp/shashum.txt \
    && sudo ln -s "$CONDADIR/etc/profile.d/conda.sh" /etc/profile.d/conda.sh \
    && echo ". $CONDADIR/etc/profile.d/conda.sh" >> "$HOME/.bashrc" \
    && find "$CONDADIR" -follow -type f -name '*.a' -delete \
    && find "$CONDADIR" -follow -type f -name '*.js.map' -delete \
    && conda clean -afy

COPY --chown="$USER_GROUP_NAME:$USER_GROUP_NAME" ./environment.yml "/tmp/$CONDAENV/environment.yml"
RUN sed -i "s/CONDAENV/$CONDAENV/g" "/tmp/$CONDAENV/environment.yml" \
    && conda env create -f "/tmp/$CONDAENV/environment.yml" \
    && echo "conda activate $CONDAENV" >> "$HOME/.bashrc"

COPY --chown="$USER_GROUP_NAME:$USER_GROUP_NAME" ./requirements.txt "/tmp/$CONDAENV/requirements.txt"
RUN set -exu \
    \
    && . "$CONDADIR/etc/profile.d/conda.sh" \
    && conda activate "$CONDAENV" \
    && pip install \
           -r "/tmp/$CONDAENV/requirements.txt" \
           -f https://download.pytorch.org/whl/torch_stable.html

WORKDIR "$WORKDIR"
