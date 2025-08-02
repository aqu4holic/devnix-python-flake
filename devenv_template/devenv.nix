{ pkgs, lib, config, inputs, ... }:
let
    version = "575.64.05";
    sha256_64bit = "sha256-hfK1D5EiYcGRegss9+H5dDr/0Aj9wPIJ9NVWP3dNUC0=";

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
        UV_PROJECT_ENVIRONMENT = lib.mkForce null;
        UV_TORCH_BACKEND = "auto";
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
