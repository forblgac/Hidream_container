# =======================
# Dockerfile（環境構築専用）
# =======================
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

# 必要パッケージと Python 3.12.3 をビルド
RUN apt update && apt install -y \
    build-essential curl wget git ca-certificates \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev libncursesw5-dev xz-utils tk-dev \
    libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
    cmake ninja-build && \
    wget https://www.python.org/ftp/python/3.12.3/Python-3.12.3.tgz && \
    tar -xzf Python-3.12.3.tgz && cd Python-3.12.3 && \
    ./configure --enable-optimizations && make -j$(nproc) && make altinstall && \
    ln -s /usr/local/bin/python3.12 /usr/bin/python3 && \
    /usr/local/bin/python3.12 -m ensurepip && \
    rm -rf /workspace/Python-3.12.3* 

# 仮想環境の作成
RUN python3 -m venv /workspace/venv
ENV PATH="/workspace/venv/bin:$PATH"
ENV TRANSFORMERS_CACHE=/root/.cache/huggingface

# ライブラリインストール（torch, hdi1 など）
RUN pip install --upgrade pip setuptools wheel && \
    pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121 && \
    pip install psutil ninja && \
    pip install hdi1 --no-build-isolation

# ポートはCompose側で定義するため不要に
# CMDもComposeで管理するので未指定