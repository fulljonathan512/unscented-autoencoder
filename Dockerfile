FROM pytorch/pytorch:2.4.0-cuda12.1-cudnn9-runtime

# Avoid interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    SKLEARN_ALLOW_DEPRECATED_SKLEARN_PACKAGE_INSTALL=True

WORKDIR /app

# Install system dependencies (git, wget, etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency definitions
COPY requirements.txt /app/requirements.txt

# Install remaining Python dependencies (torch/torchvision already provided by base image)
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /app/requirements.txt

# Copy the rest of the project
COPY . /app

# Default config for MNIST VAE training
ENV CONFIG_PATH=configs_mnist/vae.yaml

# Create a volume mount point for logs/checkpoints
# When running the container, mount a host directory here
VOLUME ["/app/logs"]

# By default, train the MNIST VAE; override CONFIG_PATH via -e if needed
CMD ["bash", "-lc", "python run.py --config ${CONFIG_PATH}"]
