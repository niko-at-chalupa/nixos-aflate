{ ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "Xanh Mono:size=14";
        prompt = "'> '";
        width = 40;
        lines = 10;
        horizontal-pad = 20;
        vertical-pad = 14;
        inner-pad = 8;
      };

      # Colours are RRGGBBAA. Palette: dark purple theme.
      colors = {
        background = "151217ff";
        text = "ffffffff";
        prompt = "ae84cfff";
        input = "ffffffff";
        placeholder = "655e76ff";
        match = "ae84cfff";
        selection = "2a1f2eff";
        selection-text = "ffffffff";
        selection-match = "ae84cfff";
        counter = "655e76ff";
        border = "7866a3ff";
      };

      border = {
        width = 2;
        radius = 10;
      };
    };
  };
}
