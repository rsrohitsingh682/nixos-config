{ lib, pkgs, flake, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Shared modules
      ../../nixos/common.nix
      ../../nixos/xrdp.nix
    ];


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "enigma";

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  users.users.${flake.config.me.username} = {
    isNormalUser = true;
    shell = lib.getExe pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      "${flake.config.me.sshKey}"
    ];
  };

  nix.settings.trusted-users = [ "root" "${flake.config.me.username}" ];

  # Workaround the annoying `Failed to start Network Manager Wait Online` error on switch.
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;

  home-manager.users."${flake.config.me.username}" = {
    imports = [
      ../../home/default.nix
    ];
    home.stateVersion = "23.11";
  };

  system.stateVersion = "23.11";
}
