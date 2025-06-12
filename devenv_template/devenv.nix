{ pkgs, lib, config, inputs, ... }:
let
    buildInputs = with pkgs; [
        stdenv.cc.cc
        libuv
        glib
        libz
        zlib
    ];
in
{
    env = { LD_LIBRARY_PATH = "${with pkgs; lib.makeLibraryPath buildInputs}"; };

    languages.python = {
        enable = true;
        # version = "3.12.7";

        uv = {
            enable = true;
        };

        # venv = {
        #     enable = true;
        # };
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
}
