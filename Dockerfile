# ===============================
# Dockerfile（環境構築専用）
# ===============================
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace

# 必要なパッケージのインストール＆キャッシュ削除
RUN apt-get update && apt-get install -y \
    build-essential curl wget git ca-certificates \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev libncursesw5-dev xz-utils tk-dev \
    libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
    cmake ninja-build && \
    rm -rf /var/lib/apt/lists/*

# Python 3.12.3 のダウンロードとビルド
RUN wget https://www.python.org/ftp/python/3.12.3/Python-3.12.3.tgz && \
    tar -xzf Python-3.12.3.tgz && cd Python-3.12.3 && \
    ./configure --enable-optimizations && \
    make -j$(nproc) && make altinstall && \
    ln -s /usr/local/bin/python3.12 /usr/bin/python3 && \
    /usr/local/bin/python3.12 -m ensurepip && \
    cd .. && rm -rf Python-3.12.3*

# 仮想環境の作成
RUN python3 -m venv /workspace/venv

# 仮想環境を優先するため PATH を設定
ENV PATH="/workspace/venv/bin:$PATH"
ENV TRANSFORMERS_CACHE=/root/.cache/huggingface

# Python ライブラリのインストール（torch, hdi1 など）
RUN pip install --upgrade pip setuptools wheel && \
    pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121 && \
    pip install psutil ninja && \
    pip install hdi1 --no-build-isolation
