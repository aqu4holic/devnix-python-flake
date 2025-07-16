{ pkgs, lib, config, inputs, ... }:
let
    buildInputs = with pkgs; [
        stdenv.cc.cc
        libuv
        glib
        libz
        zlib
        libGL
        libGLU

        # cuda support
        linuxPackages.nvidiaPackages.stable
        cudaPackages.cudatoolkit
        cudaPackages.cuda_cudart
        cudaPackages.cudnn
        cudaPackages.cuda_nvcc
        linuxKernel.packages.linux_6_15.nvidia_x11
    ];
in
{
    env = {
        LD_LIBRARY_PATH = "${with pkgs; lib.makeLibraryPath buildInputs}";
        CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
        EXTRA_LDFLAGS = "-L/lib -L${pkgs.linuxKernel.packages.linux_6_15.nvidia_x11}/lib";
        UV_PROJECT_ENVIRONMENT = lib.mkForce null;
        UV_TORCH_BACKEND = "auto";
    };

    packages = with pkgs; [
        linuxPackages.nvidiaPackages.stable
        cudaPackages.cudatoolkit
        cudaPackages.cuda_cudart
        cudaPackages.cudnn
        cudaPackages.cuda_nvcc
        linuxKernel.packages.linux_6_15.nvidia_x11
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
