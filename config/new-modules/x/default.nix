{ config, lib, pkgs, ... }:

with lib;

{

  options.mine.x.enable = mkEnableOption "X config";

  config = mkIf config.mine.x.enable {

    programs.dconf.enable = true;

    mine.dunst.enable = true;

    mine.live-wallpaper.enable = true;

    services.logind.extraConfig = ''
      HandlePowerKey=suspend
    '';

    services.xserver = {
      enable = true;
      exportConfiguration = true;

      displayManager = {
        gdm = {
          enable = true;
          autoLogin = {
            enable = false;
            user = "evanjs";
          };
          autoSuspend = false;
        };

        sessionCommands = ''
          # Set GTK_DATA_PREFIX so that GTK+ can find the themes
          export GTK_DATA_PREFIX=${config.system.path}

          # find theme engines
          export GTK_PATH=${config.system.path}/lib/gtk-3.0:${config.system.path}/lib/gtk-2.0
        '';
      };

      libinput = {
        accelProfile = "flat";
      };
    };

    xdg = {
      mime.enable = true;
    };

    mine.userConfig.xdg.mimeApps =
      let
        chromium = "chromium-browser.desktop";
      in
      {
        enable = true;
        defaultApplications = {
          "application/xhtml+xml" = chromium;
          "text/html" = chromium;
          "text/xml" = chromium;
          "x-scheme-handler/http" = chromium;
          "x-scheme-handler/https" = chromium;
        };
      };

    fonts = {
      enableFontDir = true;
      enableGhostscriptFonts = true;
      fontconfig = {
        penultimate.enable = true;
      };
      fonts = with pkgs; [
        corefonts
        (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraMono" "Noto" ]; })
        ipaexfont
        vistafonts
        noto-fonts-cjk
        noto-fonts-emoji
        # TODO: try and integrate this with emacs config so it isn't explicitly defined in the main X config
        emacs-all-the-icons-fonts
      ];
    };

    environment.systemPackages = with pkgs; [
      feh
      libnotify
      gnome3.gnome-font-viewer
      gnome3.gnome_terminal
      guake
      xclip
      #evince
      vlc
      #pcmanfm
      arandr
      xorg.xmessage
      lxappearance-gtk3
      #arc-theme
      gtk_engines
      gtk-engine-murrine
      #shotcut #video editor
      xbindkeys
      xwinwrap
      xbindkeys-config
      dmenu
      xlibs.xev
      haskellPackages.xmobar
      xtrlock-pam
      xdg-user-dirs
      dfeet
    ];


    mine.xUserConfig = {

      services.picom = {
        enable = true;
        activeOpacity = "0.90";
        blur = true;
        blurExclude = [
          "class_g = 'slop'"
        ];
        fade = true;
        fadeDelta = 5;
        vSync = true;
        opacityRule = [
          "100:class_g   *?= 'Chromium-browser'"
          "100:class_g   *?= 'Firefox'"
          "100:class_g   *?= 'gitkraken'"
          "100:class_g   *?= 'emacs'"
          "100:class_g   ~=  'jetbrains'"
          "100:class_g   *?= 'slack'"
        ];
      };

      services.unclutter = {
        enable = true;
      };

      services.redshift.enable = true;

      xsession = {
        enable = true;
        numlock.enable = true;

        pointerCursor = {
          name = "breeze_cursors";
          size = 16;
          package = pkgs.plasma5.breeze-qt5;
        };
        
       preferStatusNotifierItems = true;
      };

      home.packages = with pkgs; [
        mpv
        mine.pics
        #thunderbird
        helvetica-neue-lt-std
        mine.arcred
      ];

      programs.chromium = {
        extensions = [
          "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # 1Password X
          "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
          "gcbommkclmclpchllfjekcdonpmejbdp" # HTTPS Everywhere
          "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        ];
      };

      programs.zsh.shellAliases = {
        pbcopy = "${pkgs.xclip}/bin/xclip -selection clipboard";
        pbpaste = "${pkgs.xclip}/bin/xclip -selection clipboard -o";
        aniwp = "xwinwrap -ov -fs -ni -- mpv --loop=inf -wid WID --panscan=1";
      };

      programs.rofi = {
        enable = true;
        theme = "Monokai";
        terminal = config.mine.terminal.binary;
      };

    };
  };

}
