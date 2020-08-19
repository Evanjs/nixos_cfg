{ config, pkgs, lib, ... }:
with lib;

let
  rust-language-server = ((pkgs.latest.rustChannels.stable.rust.override { extensions = [ "rls-preview" ]; }));
  rust-nightly = pkgs.latest.rustChannels.stable.rust;
  rust-stable = pkgs.latest.rustChannels.nightly.rust;
  dag = import ../../external/home-manager/modules/lib/dag.nix { inherit lib; };
  loadPlugin = plugin: ''
    set rtp^=${plugin.rtp}
    set rtp+=${plugin.rtp}/after
  '';
  plugins = with pkgs.nixos-unstable.vimPlugins; [
    colorizer
    fugitive
    ghc-mod-vim
    haskell-vim
    LanguageClient-neovim
    latex-box
    neomake
    nerdcommenter
    nerdtree
    polyglot
    rainbow
    ranger-vim
    rust-vim
    SpaceCamp
    syntastic
    tagbar
    vim-airline
    vim-airline-themes
    vim-autoformat
    vim-illuminate
    vim-latex-live-preview
    vimtex
  ] ++ (with pkgs.stable.vimPlugins; [
    # rustracer fails to build on nixos-unstable (as of at least https://github.com/NixOS/nixpkgs/commit/467ce5a9f45aaf96110b41eb863a56866e1c2c3c)
    # rustracer seems to build fine with rustc 1.44 (see https://github.com/NixOS/nixpkgs/issues/89481#issuecomment-642853909)
    # Use stable nixpkgs until https://github.com/NixOS/nixpkgs/issues/89481 is resolved
    YouCompleteMe
  ]);
in
  {
    options.mine.vim = {
      colorscheme = mkOption {
        type = types.str;
        default = "";
        example = "nord";
        description = "The colorscheme to use for vim.";
      };
      enable = mkEnableOption "vim config";
      extraPlugins = mkOption {
        type = types.listOf types.package;
        default = [];
        example = ''
          with pkgs.vimPlugins; [
            nord-vim
          ]
        '';
        description = "Additional plugins to add to the vim configuration";
      };
    };
    config.mine.userConfig = mkIf config.mine.vim.enable {

      nixpkgs.overlays = [(self: super: {
      })];

      programs.neovim = {
        enable = true;

        viAlias = true;
        vimAlias = true;
        withPython = false;
        withPython3 = true;


        extraConfig = ''
            " Workaround for broken handling of packpath by vim8/neovim for ftplugins -- see https://github.com/NixOS/nixpkgs/issues/39364#issuecomment-425536054 for more info
            filetype off | syn off
            ${builtins.concatStringsSep "\n"
            (map loadPlugin (plugins ++ config.mine.vim.extraPlugins))}
            filetype indent plugin on | syn on

            "" General Settings {{{
            " turn on filetype detection and indentation
            " filetype indent plugin on

            " set tags file to search in parent directories with tags
            set tags=tags;

            " enable line numbers
            set number

            " Jump to last cursor position when opening files
            " See |last-position-jump|.
            :au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

            :set pastetoggle=<F2>
            :set clipboard=unnamedplus
            :set backspace=2 " make backspace work like most other programs

            :syntax on
            " }}}

            "" Theme settings {{{
            " airline :
            " for terminology you will need either to export TERM='xterm-256color'
            " or run it with '-2' option
            let g:airline_powerline_fonts = 1
            set laststatus=2
            au VimEnter * exec 'AirlineTheme wombat'
            colorscheme ${config.mine.vim.colorscheme}
            "}}}

            "" Syntastic settings {{{
            set statusline+=%#warningmsg#
            set statusline+=%#{SyntasticStatuslineFlag()}
            set statusline+=%*

            let g:syntastic_always_populate_loc_list = 1
            let g:syntastic_auto_loc_list = 1
            let g:syntastic_check_on_wq = 0
            "}}}

            "" Language Client Settings {{{
            let g:LanguageClient_autoStart = 1

            nnoremap <F5>  :call LanguageClient_contextMenu()<CR>
            nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
            nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
            nnoremap <silent> <F6> :call LanguageClient#textDocument_rename()<CR>

            "map <Leader>lk :call LanguageClient#textDocument_hover()<CR>
            "map <Leader>lg :call LanguageClient#textDocument_definition(<CR>
            "map <Leader>lr :call LanguageClient#textDocument_rename()<CR>
            "map <Leader>lf :call LanguageClient#textDocument_formatting()<CR>
            "map <Leader>lb :call LanguageClient#textDocument_references()<CR>
            "map <Leader>la :call LanguageClient#textDocument_codeAction()<CR>
            "map <Leader>ls :call LanguageClient#textDocument_documentSymbol()<CR>
            " }}}

            "" Indentation {{{
            au FileType haskell         setl sw=4 sts=2 et
            au FileType json            setl sw=2 sts=2 et
            au FileType javascript      setl sw=2 sts=2 et
            au FileType js              setl sw=2 sts=2 et
            au FileType javascript.jsx  setl sw=2 sts=2 et
            au FileType php             setl sw=2 sts=2 et
            au FileType markdown        setl sw=2 sts=2 et
            au FileType qml             setl sw=2 sts=2 et
            au FileType yaml            setl sw=2 sts=2 et
            au FileType nix             setl sw=2 sts=2 et
            au FileType Jenkinsfile     setl sw=2 sts=2 et
            au FileType groovy          setl sw=2 sts=2 et
            au FileType python          setl sw=2 sts=2 et
            au FileType kv              setl sw=2 sts=2 et
            au FileType typescript      setl sw=2 sts=2 et
            au FileType ts              setl sw=2 sts=2 et
            "}}}

            "" Rust Settings {{{
            let g:rustfmt_autosave = 1
            let g:LanguageClient_serverCommands = { 'rust': ['${rust-stable}/bin/rls'] }
            "}}}

            "" Tagbar Settings {{{
            nmap <F8> :TagbarToggle<CR>

            " Width of the Tagbar window in characters.
            let g:tagbar_width = 80

            " Width of the Tagbar window when zoomed.
            " Use the width of the longest currently visible tag.
            let g:tagbar_zoomwidth = 0
            "}}}


            "" YouCompleteMe Settings {{{
            let g:ycm_server_keep_logfiles = 0
            "}}}

            "" Tex Settings {{{
            let g:vimtex_log_verbose = 1
            let g:livepreview_previewer = '${pkgs.okular}/bin/okular'
            "}}}

            "" Misc Settings {{{
            let g:rainbow_active = 1
            "}}}

        '';
      };
    };
  }

