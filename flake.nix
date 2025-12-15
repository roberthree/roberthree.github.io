{
  inputs = {
    nixpkgs.url = "nixpkgs/25.05";
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      git-hooks,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        checks = {
          pre-commit-check = git-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              cspell = {
                enable = true;
                args = [
                  "--no-must-find-files"
                ];
              };

              nixfmt-rfc-style.enable = true;

              markdownlint = {
                enable = true;
                files = "\\.qmd$";
              };

              prettier.enable = true;

              yamlfmt = {
                enable = true;
                settings = {
                  lint-only = false;
                };
              };
            };
          };
        };

        formatter =
          let
            inherit (self.checks.${system}.pre-commit-check.config) package configFile;
            script = ''
              ${package}/bin/pre-commit run --all-files --config ${configFile}
            '';
          in
          pkgs.writeShellScriptBin "pre-commit-run" script;

        packages = {
          quartoRender = pkgs.stdenv.mkDerivation {
            pname = "quarto-render";
            version = "1.0.0";
            src = ./quarto;
            nativeBuildInputs = with pkgs; [
              pkgs.quarto
            ];
            dontInstall = true;
            buildPhase = ''
              export HOME=$TMPDIR
              quarto render --output-dir "$out"
            '';
          };
        };

        devShells.default = pkgs.mkShell {
          name = "roberthree";

          inputsFrom = [
            self.checks.${system}.pre-commit-check
          ];

          packages = with pkgs; [
            quarto
          ];
        };
      }
    );
}
