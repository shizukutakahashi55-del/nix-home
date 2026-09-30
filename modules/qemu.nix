{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    qemu
    virt-manager
  ];

  virtualisation.libvirtd.enable = true;

  users.users.oozenix.extraGroups = [
    "libvirtd"
  ];
}
