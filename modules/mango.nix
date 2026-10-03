{ pkgs, inputs, ... }:

{
  # ─────────────────────────────────────────────
  # MangoWM
  # ─────────────────────────────────────────────

  imports = [
    inputs.mangowm.nixosModules.mango
  ];

  programs.mango.enable = true;

  # ─────────────────────────────────────────────
  # XDG Desktop Portal
  # ─────────────────────────────────────────────

#   xdg.portal = {
#     enable = true;

#     extraPortals = [
#       pkgs.xdg-desktop-portal-wlr
#       pkgs.xdg-desktop-portal-gtk
#     ];

#     config = {
#       mango = {
#         default = "gtk";

#         "org.freedesktop.impl.portal.ScreenCast" = "wlr";
#         "org.freedesktop.impl.portal.Screenshot" = "wlr";
#       };
#     };
#   };
#   xdg.portal.wlr.settings.screencast = {
#   chooser_type = "none";
#   output_name = "HDMI-A-1";   # tu monitor: mmsg get all-monitors
# };

}