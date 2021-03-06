{ pkgs, config, lib, epkgs, dag, ... }:

# TODO: Add projects option to figure out what GHC versions we need


with lib;

let

  all-hies = import (import ../../nix/sources.nix {}).all-hies {};

  hie = all-hies.combined {
    inherit (all-hies.versions) ghc883;
  };

in

{

  options.haskell = mkOption {
    type = types.bool;
    default = false;
    description = "Haskell emacs stuff";
  };

  config = mkIf config.haskell {
    lsp = true;

    packages = with epkgs; [
      lsp-haskell
      haskell-mode
      hasky-extensions
    ];

    #;(setq lsp-haskell-process-path-hie "${hie}/bin/hie-wrapper")
    #;(setq lsp-haskell-process-args-hie (quote ("--vomit" "-d" "-l" "/tmp/hie.log")))
    init.hs = ''
      (require 'lsp-haskell)

      (defun hasky-keys ()
        "Hasky extension key binds"
        (require 'hasky-extensions)
        (local-set-key (kbd "C-c C-y") #'hasky-extensions))

      (setq haskell-stylish-on-save t)

      (add-hook 'haskell-mode-hook (lambda () (haskell-indentation-mode nil)))
      (add-hook 'haskell-mode-hook 'hasky-keys)
      (add-hook 'haskell-mode-hook 'lsp)
      (add-hook 'haskell-mode-hook 'direnv-update-environment)
    '';
  };
}
