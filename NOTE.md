# pytorch with uv

here's an example of a `pyproject.toml` file that uses `uv` to manage PyTorch and torchvision dependencies with CUDA 12.8 support.

```
[project]
name = "fpt-ai-challenge"
version = "0.1.0"
description = "Add your description here"
readme = "README.md"
requires-python = ">=3.11"
dependencies = [
    "ipykernel>=6.29.5",
    "pandas>=2.3.0",
    "scikit-learn>=1.7.0",
    "torch>=2.7.1",
    "tqdm>=4.67.1",
    "transformers>=4.52.4",
]

[tool.uv.sources]
torch = [
    { index = "pytorch-cu128" },
]
torchvision = [
    { index = "pytorch-cu128" },
]

[[tool.uv.index]]
name = "pytorch-cu128"
url = "https://download.pytorch.org/whl/cu128"
explicit = true
```