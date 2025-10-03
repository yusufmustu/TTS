FROM python:3.11-slim

# Sistem güncellemesi ve bağımlılıklar
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends \
    gcc g++ make \
    python3 python3-dev python3-pip python3-venv python3-wheel \
    espeak-ng libsndfile1-dev \
    && rm -rf /var/lib/apt/lists/*

# LLVM lite kurulumu
RUN pip3 install llvmlite --ignore-installed

# PyTorch kurulumu (CPU versiyonu - Railway'de GPU yoksa)
RUN pip3 install torch torchaudio --index-url https://download.pytorch.org/whl/cpu
RUN rm -rf /root/.cache/pip

# TTS repository içeriğini kopyala
WORKDIR /root
COPY . /root

# TTS'i kur
RUN make install

# Lisans otomatik onayı
ENV COQUI_TOS_AGREED=1

# Railway PORT değişkeni
ENV PORT=8000
EXPOSE 8000

# Model dosyalarının konumu
ENV MODEL_PATH=/root/.local/share/tts/tts_models--multilingual--multi-dataset--xtts_v2

# Önce modeli indir
RUN python3 -c "from TTS.utils.manage import ModelManager; manager = ModelManager(); manager.download_model('tts_models/multilingual/multi-dataset/xtts_v2')"

# TTS sunucusunu başlat
CMD python3 -m TTS.server.server \
    --model_path $MODEL_PATH/model.pth \
    --config_path $MODEL_PATH/config.json \
    --port $PORT
