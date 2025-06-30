FROM python:3.11.13-slim AS build_final_image

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_PREFER_BINARY=1 \
    ROOT=/stable-diffusion-webui \
    PYTHONUNBUFFERED=1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Установка зависимостей
RUN apt-get update && \
    apt install -y \
    fonts-dejavu-core rsync git curl jq moreutils aria2 wget libgoogle-perftools-dev libtcmalloc-minimal4 procps libgl1 libglib2.0-0 && \
    apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && apt-get clean -y

# Клонирование WebUI
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git  /stable-diffusion-webui && \
    cd /stable-diffusion-webui && \
    git reset --hard v1.10.1 && \
    pip install xformers && \
    pip install -r requirements_versions.txt && \
    python -c "from launch import prepare_environment; prepare_environment()" --skip-torch-cuda-test

# Установка пользовательских зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Загрузка моделей (в конце)
RUN mkdir -p /stable-diffusion-webui/models/Stable-diffusion /stable-diffusion-webui/models/Lora && \
    # Основная модель
#    wget -q -O /stable-diffusion-webui/models/Stable-diffusion/model.safetensors https://huggingface.co/luisrguerra/real-dream-xl-pony-releases/resolve/main/pony-16-real-dream.safetensors  && \
    # LoRA модель 1
    DIRECT_URL=$(sh -c "curl -s -H \"Authorization: Bearer ea752a8d247748a3db45cf86d8f4684c\" https://civitai.com/api/download/models/1920523")  && \
    wget -q --trust-server-names -O /model.safetensors "$DIRECT_URL" && \
    # LoRA модель 2
    DIRECT_URL=$(sh -c "curl -s -H \"Authorization: Bearer ea752a8d247748a3db45cf86d8f4684c\" https://civitai.com/api/download/models/1891887")  && \
    wget -q --trust-server-names -O /stable-diffusion-webui/models/Lora/mimimeter_2.safetensors "$DIRECT_URL" && \
    # Чистка
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY test_input.json .

ADD src .

RUN chmod +x /start.sh
CMD /start.sh
