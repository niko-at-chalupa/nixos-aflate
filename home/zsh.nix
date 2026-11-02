{ pkgs, inputs, ... }:

{
  programs.zsh = {
    enable = true;
    envExtra = ''
      export PATH="$HOME/.local/bin:$PATH"
      [[ ! -f "$HOME/.rokit/env" ]] || source "$HOME/.rokit/env"
    '';
    oh-my-zsh = {
      enable = true;
      custom = "${pkgs.zsh-powerlevel10k}/share/zsh";
      plugins = [ "git" ];
      theme = "powerlevel10k/powerlevel10k";
    };
    initContent = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      autoload -U up-line-or-beginning-search down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search

      # Re-bind Up/Down arrows across standard keymaps
      for km in main viins vicmd; do
        bindkey -M $km '^[[A' up-line-or-beginning-search
        bindkey -M $km '^[OA' up-line-or-beginning-search
        bindkey -M $km '^[[B' down-line-or-beginning-search
        bindkey -M $km '^[OB' down-line-or-beginning-search

        [[ -n "''${terminfo[kcuu1]}" ]] && bindkey -M $km "''${terminfo[kcuu1]}" up-line-or-beginning-search
        [[ -n "''${terminfo[kcud1]}" ]] && bindkey -M $km "''${terminfo[kcud1]}" down-line-or-beginning-search
      done
    '';
  };

  home.sessionPath = [
    "$HOME/.nix-profile/bin"
    "$HOME/.cargo/bin"
    "$HOME/.npm-global/bin"
  ];
  home.sessionVariables.EDITOR = "nvim";
}
