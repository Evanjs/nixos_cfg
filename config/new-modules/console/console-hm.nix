{ config, pkgs, lib, ... }:
{
  programs = {
    git = {
      userName = "Evan Stoll";
      userEmail = "evanjsx@gmail.com";
      enable = true;
      delta = {
        enable = true;
        options = {
          decorations = {
            commit-decoration-style = "bold yellow box ul";
            file-decoration-style = "none";
            file-style = "bold yellow ul";
          };
          features = "decorations";
          line-numbers = true;
          whitespace-error-style = "22 reverse";
        };
      };
    };
    broot = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    direnv = { enable = true; };
    htop.enable = true;

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;

      settings = {
        line_break.disabled = true;
        git_branch.style = "bold green";
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;

      history.size = 1000000;
    };
  }; 
}
