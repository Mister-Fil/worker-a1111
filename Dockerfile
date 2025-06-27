# ---------------------------------------------------------------------------- #
#                         Stage 1: Download the models                         #
# ---------------------------------------------------------------------------- #
FROM alpine/git:2.49.0 AS download

RUN apk add --no-cache wget curl && \
    wget -q -O /model.safetensors https://huggingface.co/luisrguerra/real-dream-xl-pony-releases/resolve/main/pony-16-real-dream.safetensors && \
    DIRECT_URL=$(sh -c 'curl -s -H "Authorization: Bearer ea752a8d247748a3db45cf86d8f4684c" "https://civitai.com/api/download/models/1891887"')  && \
    wget -q --trust-server-names -O /mimimeter_2.safetensors "$DIRECT_URL" && \
    apk del curl && \
    rm -rf /var/cache/apk/*

# ---------------------------------------------------------------------------- #
#                        Stage 2: Build the final image                        #
# ---------------------------------------------------------------------------- #
FROM python:3.11.13-slim AS build_final_image

#ARG A1111_RELEASE=v1.9.3
ARG A1111_RELEASE=v1.10.1

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_PREFER_BINARY=1 \
    ROOT=/stable-diffusion-webui \
    PYTHONUNBUFFERED=1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    apt install -y \
    fonts-dejavu-core rsync git jq moreutils aria2 wget libgoogle-perftools-dev libtcmalloc-minimal4 procps libgl1 libglib2.0-0 && \
    apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && apt-get clean -y

RUN --mount=type=cache,target=/root/.cache/pip \
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git && \
    cd stable-diffusion-webui && \
    git reset --hard ${A1111_RELEASE} && \
    pip install xformers && \
    pip install -r requirements_versions.txt && \
    python -c "from launch import prepare_environment; prepare_environment()" --skip-torch-cuda-test

COPY --from=download /model.safetensors /model.safetensors
#COPY models/cyberrealisticPony_v120.safetensors /model.safetensors
#COPY models/cyberrealisticPony_v120.json /model.json
COPY --from=download /mimimeter_2.safetensors /stable-diffusion-webui/models/Lora/

# install dependencies
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir -r requirements.txt

COPY test_input.json .

ADD src .

RUN chmod +x /start.sh
CMD /start.sh
