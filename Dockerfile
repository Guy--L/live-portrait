# Use an official CUDA base image from NVIDIA
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04

# Set environment variables for Conda
ENV PATH="/opt/conda/bin:$PATH"

# Install dependencies
RUN apt-get update && apt-get install -y     git     wget     && rm -rf /var/lib/apt/lists/*

# Install Conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh &&     bash /tmp/miniconda.sh -b -p /opt/conda &&     rm /tmp/miniconda.sh &&     /opt/conda/bin/conda clean -a -y

RUN apt-get update && apt-get install -y libgl1-mesa-glx

# Clone the LivePortrait repository
RUN git clone --branch feature/docker-deployment https://github.com/Guy--L/live-portrait.git /workspace/LivePortrait

# Set the working directory
WORKDIR /workspace/LivePortrait

# Create Conda environment and install dependencies
RUN conda create -n LivePortrait python=3.9 -y && /bin/bash -c "source activate LivePortrait && conda install ffmpeg -y && pip install torch==2.3.0 torchvision==0.18.0 torchaudio==2.3.0 --index-url https://download.pytorch.org/whl/cu118 && pip install -r requirements.txt && pip install -U 'huggingface_hub[cli]' && huggingface-cli download KwaiVGI/LivePortrait --local-dir pretrained_weights --exclude '*.git*' 'README.md' 'docs'"

EXPOSE 5000

# Set the default command to activate the Conda environment
CMD ["bash", "-c", "source activate LivePortrait && python api.py"]
