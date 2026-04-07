{ pkgs, ... }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    # keep-sorted start
    git
    mask
    nix-unit
    dhall
    dhall-json
    dhall-nix
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
