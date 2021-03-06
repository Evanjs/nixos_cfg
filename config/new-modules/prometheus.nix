{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.mine.prometheus;
in
  {
    options.mine.prometheus = {
      server.enable = mkEnableOption "prometheus server";
      export.enable = mkEnableOption "various exporters for prometheus";
    };

    config = mkMerge [
      (mkIf (cfg.server.enable) {
        services.prometheus.enable = true;
        networking.firewall.allowedTCPPorts = [ 9090 ];
      })
      (mkIf (cfg.export.enable) {
        services.prometheus = {
          exporters = {
            node = {
              enable = true;
              enabledCollectors = [
                "conntrack"
                "diskstats"
                "entropy"
                "filefd"
                "filesystem"
                "loadavg"
                "mdadm"
                "meminfo"
                "netdev"
                "netstat"
                "stat"
                "time"
                "vmstat"
                "systemd"
                "logind"
                "interrupts"
                "ksmd"
              ];
              openFirewall = true;
            };
          };

          scrapeConfigs = [
            {
              job_name = "node";
              static_configs = [
                {
                  targets = [ "127.0.0.1:9100" ];
                  labels = { instance = config.networking.hostName; };
                }
                {
                  targets = [ "172.16.0.209:9100" ];
                  labels = { instance = "sekka"; };
                }
              ];
            }
            {
              job_name = "prometheus";
              static_configs = [
                {
                  targets = [ "127.0.0.1:9090" ];
                  labels = { instance = config.networking.hostName; };
                }
              ];
            }
          ];
        };
      })
      (mkIf (cfg.export.enable && config.services.postgresql.enable) {
        services.prometheus = {
          exporters.postgres = {
            enable = true;
            openFirewall = true;
            runAsLocalSuperUser = true;
          };
          scrapeConfigs = [
            {
              job_name = "postgres";
              static_configs = [
                {
                  targets = [ "127.0.0.1:9187" ];
                  labels = { instance = config.networking.hostName; };
                }
                {
                  targets = [ "172.16.0.209:9187" ];
                  labels = { instance = "sekka"; };
                }
              ];
            }
          ];
        };
      })
    ];
  }

