{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    rustup
  ];

  systemd.timers.rustupup = {
    enable = true;
    wantedBy = [ "timers.target"];
    partOf = [ "rustupup.service" ];
    timerConfig.OnCalendar = "*-*-* *:00:00";
  };

  systemd.user.services.rustupup  = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    description = "Updates the installed Rust toolchains via `rustup update`";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.rustup.outPath}/bin/rustup update";
    };
  };

}
