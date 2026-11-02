{ ... }:

{
  services.mako = {
    enable = true;
    settings = {
      font = "Roboto Mono 11";
      # Summary in Xanh Mono, body in the font above.
      markup = true;
      format = "<span font='Xanh Mono 13'><b>%s</b></span>\\n%b";

      anchor = "top-right";
      width = 360;
      margin = "12";
      padding = "14";
      border-size = 2;
      border-radius = 10;
      default-timeout = 6000;

      background-color = "#151217";
      text-color = "#FFFFFF";
      border-color = "#7866A3";
      progress-color = "over #2A1F2E";

      "urgency=low" = {
        border-color = "#2C2D38AF";
        text-color = "#655E76";
      };

      "urgency=critical" = {
        background-color = "#382C35";
        text-color = "#EDAECB";
        border-color = "#EDAECB";
        default-timeout = 0;
      };
    };
  };
}
