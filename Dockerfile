FROM python:3.11

# Set up any installation dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Clone the assigned repository
RUN git clone https://github.com/aknecht26/pytorch_geometric /repo

# Set working directory
WORKDIR /repo

# Install required dependencies from pyproject.toml first
RUN pip install --no-cache-dir numpy
RUN pip install --no-cache-dir aiohttp fsspec jinja2 psutil>=5.8.0 pyparsing requests tqdm xxhash

# Install PyTorch and PyG dependencies
RUN pip install --no-cache-dir torch
RUN pip install --no-cache-dir pyg_lib torch_scatter torch_sparse torch_cluster torch_spline_conv -f https://data.pyg.org/whl/torch-$(python -c "import torch; print(torch.__version__.split('+')[0])")+cpu.html || echo "PyG extensions not available for this PyTorch version, continuing without them"

# Install the package in editable mode
RUN pip install -e .

# Create the repo_info.json
RUN cat > /repo_info.json <<EOF
{
  "repo_dir": "/repo",
  "pytest_rootdir": "/repo/test",
  "abs_path_to_toplevel_init": "/repo/torch_geometric/__init__.py",
  "basic_import_statement": "import torch_geometric"
}
EOF

# Copy the health verification script
COPY repo_health_verification.py /repo_health_verification.py

# Default to bash shell to keep container running
CMD ["bash"]
