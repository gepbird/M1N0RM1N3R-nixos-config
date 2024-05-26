{pkgs, ...}: {
  home.packages = with pkgs; [
    nushellFull
    starship
  ];

  programs = {
    starship = {
      enable = true;
      #presets = [
      #  "nerd-font-symbols"
      #];
      settings = {
        shell.disabled = false;
      };
      enableNushellIntegration = true;
      enableBashIntegration = true;
      #interactiveOnly = true;
    };
    nushell = {
      enable = true;
      package = pkgs.nushellFull;
      extraConfig = ''
        $env.config.show_banner = false
      '';
    };
  };
}
