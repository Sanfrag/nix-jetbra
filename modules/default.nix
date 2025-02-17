{ lib, ... }:

{
  imports = [ ./jetbra.nix ];

  options.programs.jetbra.enable = lib.mkEnableOption ''
    rocket powered garment
  '';
}
