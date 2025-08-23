# pytorch with uv

here's an example of a `pyproject.toml` file that uses `uv` to manage PyTorch and torchvision dependencies with CUDA 12.8 support.

```toml
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

## issue with `UV_TORCH_BACKEND=auto`
it wont resolve the torch backend, gonna set it manually like the above

# inputs channel
i would not recommend using the `unstable` branch (inside the `devenv.yaml`), because it will mismatch the nvidia driver version with your system's. i suggest 2 ways:
- fork this repo, add a `devenv.lock` (with the `nvidia-x11` version matching your system) in the `devenv_template` folder
- create an overlay in the `devenv.nix` file, which i pushed with this commit (my version gotta have a patch and it took me 3 hours to fix this 💀)

# python version
this supports 2 ways:
- use `languages.python.version` option in `devenv`
- use `uv python install` with `nix-ld`:
```nix
    programs.nix-ld = {
        enable = true;

        libraries = with pkgs; [
            stdenv.cc.cc
            libuv
            glib
            # libz
            zlib
        ];
    };
```
