{ pkgs, lib, config, ... }:
let
    version = "570.172.08";
    sha256_64bit = "sha256-AlaGfggsr5PXsl+nyOabMWBiqcbHLG4ij617I4xvoX0=";

    # Define customNvidia using the overridden pkgs
    customNvidia = pkgs.linuxKernel.packages.linux_6_15.nvidia_x11.overrideAttrs (old: {
        version = version;
        src = pkgs.fetchurl {
            url = "https://download.nvidia.com/XFree86/Linux-x86_64/${version}/NVIDIA-Linux-x86_64-${version}.run";
            sha256 = sha256_64bit;
        };
    });

    buildInputs = with pkgs; [
        stdenv.cc.cc
        libuv
        glib
        # libz
        zlib
        libGL
        libGLU

        # cuda support
        customNvidia
        cudaPackages.cudatoolkit
    ];
in
{
    env = {
        LD_LIBRARY_PATH = "${lib.makeLibraryPath buildInputs}";
        CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
        EXTRA_LDFLAGS = "-L/lib -L${customNvidia}/lib";

        # uv settings because devenv sucks
        # should read: https://docs.astral.sh/uv/reference/environment/
        UV_PROJECT_ENVIRONMENT = lib.mkForce null; # change the default .venv path
        UV_TORCH_BACKEND = "auto";
        UV_PYTHON_DOWNLOADS = lib.mkForce "manual"; # allow custom python version
    };

    packages = with pkgs; [
        customNvidia
        cudaPackages.cuda_cudart
        cudaPackages.cudnn
        cudaPackages.cuda_nvcc
    ];

    languages.python = {
        enable = true;

        uv = {
            enable = true;
        };
    };

    scripts = {
        uca.exec = ''
            uv venv
            source .venv/bin/activate
        '';

        upip.exec = ''
            uv pip
        '';

        pip.exec = ''
            uv pip
        '';
    };

    enterShell = ''
        source .venv/bin/activate
    '';
}
