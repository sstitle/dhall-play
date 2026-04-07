{ pkgs, ... }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    # keep-sorted start
    dhall
    dhall-json
    dhall-nix
    git
    mask
    nix-unit
    # keep-sorted end
  ];

  shellHook = ''
    echo "🚀 Development environment loaded!"
    echo "Available tools:"
    echo "  - mask: Task runner"
    echo ""
    echo "Run 'mask --help' to see available tasks."
    echo "Run 'nix fmt' to format all files."
  '';
}
