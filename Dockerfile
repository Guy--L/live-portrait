# Base image with Python and CUDA support (Choose the right version for your models)
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04

# Set the working directory inside the container
WORKDIR /app

# Install Python, pip, and other dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy your project files into the container
COPY . /app

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# (Optional) Set environment variables if needed
ENV MODEL_DIR=/app/pretrained_weights

# Expose any necessary ports (if your app has a web interface or API)
EXPOSE 8000

# Command to run your application
CMD ["python3", "inference.py"]
