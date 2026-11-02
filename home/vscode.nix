{ pkgs, ... }:

let
  nikos-vscode-theme = pkgs.vscode-utils.buildVscodeExtension {
    pname = "nikos-vscode-theme";
    version = "1.0.0";
    vscodeExtPublisher = "niko";
    vscodeExtName = "nikos-vscode-theme";
    vscodeExtUniqueId = "niko.nikos-vscode-theme";
    src = pkgs.fetchFromGitHub {
      owner = "niko-at-chalupa";
      repo = "nikos-vscode-theme";
      rev = "881cbf2592d39e9908eff80b3b54a6289273e159";
      hash = "sha256-HW1+qcQTmZqILLz3q/bkckaMIg7cF7xq4hkWh1uceZg=";
    };
    sourceRoot = "source";
  };
in
{
  programs.vscode = {
    enable = true;
    profiles.default.extensions = [ nikos-vscode-theme ];
  };
}
