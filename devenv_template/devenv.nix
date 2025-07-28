{ pkgs, lib, config, inputs, ... }:
let
    # Fetch the patch for GPL symbol issues with Linux 6.15
    gpl_symbols_linux_615_patch = pkgs.fetchpatch {
        url = "https://github.com/CachyOS/kernel-patches/raw/914aea4298e3744beddad09f3d2773d71839b182/6.15/misc/nvidia/0003-Workaround-nv_vm_flags_-calling-GPL-only-code.patch";
        hash = "sha256-YOTAvONchPPSVDP9eJ9236pAPtxYK5nAePNtm2dlvb4=";
        stripLen = 1;
        extraPrefix = "kernel/";
    };

    # Define customNvidia using the overridden pkgs
    customNvidia = pkgs.linuxKernel.packages.linux_6_15.nvidia_x11.overrideAttrs (old: {
        version = "570.153.02";
        src = pkgs.fetchurl {
            url = "https://download.nvidia.com/XFree86/Linux-x86_64/570.153.02/NVIDIA-Linux-x86_64-570.153.02.run";
            sha256 = "148886e4f69576fa8fa67140e6e5dd6e51f90b2ec74a65f1a7a7334dfa5de1b6";
        };
        patches = [ gpl_symbols_linux_615_patch ];
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