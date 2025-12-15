# Quarto website for roberthree.github.io

- The [Quarto website project](https://quarto.org/docs/websites/) is located in `./quarto/`.
- `nix develop` provides a [Nix shell](https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-mkShell) for working with [Quarto](https://github.com/quarto-dev/quarto-cli).
- `nix build .#quarto_render` renders the website at `./result`.

