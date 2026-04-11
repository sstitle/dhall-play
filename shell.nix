{ pkgs, ... }:
let
  pythonWithPytest = pkgs.python3.withPackages (ps: [ ps.pytest ]);
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    # keep-sorted start
    dhall
    dhall-json
    dhall-nix
    git
    mask
    nix-unit
    pythonWithPytest
    # keep-sorted end
  ];

  shellHook = ''
    echo "🚀 Development environment loaded!"
    echo "Lifecycle: mask run | mask format | mask lint | mask test"
    echo "Run 'mask --help' for details."
  '';
}
