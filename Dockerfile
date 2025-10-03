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

# TTS sunucusunu başlat (model ilk çalıştırmada indirilecek)
CMD ["python3", "-m", "TTS.server.server", \
     "--model_name", "tts_models/multilingual/multi-dataset/xtts_v2", \
     "--host", "0.0.0.0", \
     "--port", "8000"]
