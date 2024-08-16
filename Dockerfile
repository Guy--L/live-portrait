# Use the CUDA image with cuDNN support
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04

# Set the working directory inside the container
WORKDIR /app

# Install Python and pip
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Optional: Create a symlink for python3 to be accessed via python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Copy your project files into the container
COPY . /app

# Install Python dependencies
RUN pip3 install --upgrade pip setuptools wheel
RUN pip3 install --no-cache-dir -r requirements.txt

# (Optional) Set environment variables if needed
ENV MODEL_DIR=/app/pretrained_weights

# Expose any necessary ports (if your app has a web interface or API)
EXPOSE 23405

# Command to run your application
CMD ["python", "inference_api.py"]
