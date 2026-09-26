{ pkgs, ... }:

{
  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    hyprpolkitagent
  ];

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        subject.isInGroup("wheel") &&
        subject.active
      ) {
        return polkit.Result.AUTH_ADMIN_KEEP;
      }
    });
  '';
}