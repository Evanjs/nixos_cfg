{ lib, config, pkgs, ... }:
with lib;
{
  options.mine.dev.haskell.enable = mkEnableOption "Haskell dev config";

  config = mkIf config.mine.dev.haskell.enable {
    environment.systemPackages = with pkgs; [
      stable.haskellPackages.stylish-haskell
      haskellPackages.hlint
    ];

    mine.userConfig = {
      home.file.".ghci".text = ''
        :set prompt "\ESC[94m\STX \ESC[m\STX "
      '';
    };
  };
}
