# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./shell.nix
  ];

  home = {
    username = "ps";
    homeDirectory = "/home/ps";
    packages =
      (with pkgs; [
        vscodium # Libre VS Code build
        kdenlive
        arrpc # Handles rich presence for Vesktop
        poetry # Python dependency manager
        bitwarden
      ])
      ++ (with pkgs-unstable; [
        brave # Browser of choice with built-in adblock, built on Chromium
        vesktop # 3rd-party Discord client with MUCH better screenshare support on Linux
        osu-lazer-bin # must... click... CIRCLES!
      ]);
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      userName = "M1N3R";
      userEmail = "m1n0rm1n3r@proton.me";
    };
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-tuna
        obs-text-pthread
        obs-pipewire-audio-capture
      ];
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
