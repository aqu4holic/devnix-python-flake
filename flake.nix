{
    description = "Nix flake template for devenv Python on NixOS.";
    outputs = { ... }:
    {
        templates = {
            default = {
                path = ./devenv_template;
            };
        };
    };
}