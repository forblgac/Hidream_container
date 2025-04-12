# HDI1 Docker Environment

このリポジトリは [hdi1](https://pypi.org/project/hdi1/) を GPU 対応環境で動作させるための Dockerfile と docker-compose 設定ファイルをまとめたものです。

要 nvidia-docker。

Ubuntu on RTX 3090, およびwsl Ubuntu on RTX 3080で動作確認済み。
処理時間はRTX 3080で1分/枚程度。  
初回実行時はモデルDLのため時間がかかります。  
wslでDLが途中で止まってしまった場合、Containerを再起動すれば動くと思われます。
## 構成

- **Dockerfile**  
  CUDA 12.1.1 / cuDNN8 のベースイメージ上に必要なライブラリをインストールし、Python 3.12.3 をソースビルド。仮想環境を作成して `hdi1`（および依存ライブラリ）をインストールしています。

- **docker-compose.web.yml**  
  Web UI を起動するための設定ファイル。  
  ホストのポート `7860` をコンテナにマッピングし、Gradio のサーバーを `0.0.0.0` で待ち受けます。

- **docker-compose.gen.yml**  
  画像生成を行うための設定ファイル。  
  コマンド内でサンプルのプロンプトと出力先を指定しています。用途に応じて変更してください。  
  ※ 画像生成時の出力先 `./outputs` はホストと共有しているので、生成された画像はホスト側で確認できます。

## ビルドと起動方法

### 前提条件

- Docker および docker-compose がインストール済みであること  
- GPU を利用する場合は、[NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) の設定が完了していること

### 1. Web UI を起動する場合

1. イメージのビルドとコンテナの起動
   ターミナルで以下を実行してください。

   ```bash
   docker-compose -f docker-compose.web.yml up --build
   ```

2. ブラウザで http://localhost:7860 にアクセスしてください。

### 2. 画像生成を実行する場合
devモデルがwebuiにてOOMで動作しなかったため、別途作成。

1. Promptの編集
   `docker-compose.gen.yml`の`command`にてPromptを変更してください。
2. イメージのビルドとコンテナの起動
   ターミナルで以下を実行してください。

   ```
   docker-compose -f docker-compose.gen.yml up --build
   ```
   コマンド内で指定されたプロンプトに基づいて画像が生成され、指定した出力先（例: ./outputs/output.png）に保存されます。
