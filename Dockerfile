# ---------------------------------------------------------------------------- #
#                         Stage 1: Download the models                         #
# ---------------------------------------------------------------------------- #
FROM alpine/git:2.43.0 as download

# NOTE: CivitAI usually requires an API token, so you need to add it in the header
#       of the wget command if you're using a model from CivitAI.
RUN apk add --no-cache wget && \
    wget -q -O /model.safetensors https://huggingface.co/luisrguerra/real-dream-xl-pony-releases/resolve/main/pony-16-real-dream.safetensors && \
    wget -q -O /mimimeter_2.safetensors "https://civitai-delivery-worker-prod.5ac0637cfd0766c97916cefa3764fbdf.r2.cloudflarestorage.com/model/139142/mimimeter.uQ5g.safetensors?X-Amz-Expires=86400&response-content-disposition=attachment%3B%20filename%3D%22mimimeter.safetensors%22&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=e01358d793ad6966166af8b3064953ad/20250626/us-east-1/s3/aws4_request&X-Amz-Date=20250626T171631Z&X-Amz-SignedHeaders=host&X-Amz-Signature=6c902db88a47a8f35550b7bce21c746d29292303cae1bbb9cbe36f760b9519c8"


# ---------------------------------------------------------------------------- #
#                        Stage 2: Build the final image                        #
# ---------------------------------------------------------------------------- #
FROM python:3.10.14-slim as build_final_image

ARG A1111_RELEASE=v1.9.3
#ARG A1111_RELEASE=v1.10.1

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
COPY --from=download /mimimeter_2.safetensors /stable-diffusion-webui/models/Lora/mimimeter_2.safetensors

# install dependencies
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir -r requirements.txt

COPY test_input.json .

ADD src .

RUN chmod +x /start.sh
CMD /start.sh
