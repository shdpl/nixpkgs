{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.bitcoind;

  confFile = pkgs.writeText "bitcoin.conf" ''
  '';

  bitcoindCli = "${cfg.package}/bin/bitcoind -conf=${cfg.configFile}"
    + pkgs.stdenv.lib.optionalString cfg.txindex " -txindex"
    + pkgs.stdenv.lib.optionalString cfg.gen " -gen";

in
{
  ###### interface
  options = {

    services.bitcoind = {

      enable = mkOption {
        default = false;
        description = ''
          Whether to enable bitcoind classic.
        '';
      };

      package = mkOption {
        default = pkgs.altcoins.bitcoind;
        defaultText = "pkgs.altcoins.bitcoind";
        description = "Which bitcoind derivation to use.";
        type = types.package;
      };

      user = mkOption {
        default = "bitcoind";
        description = "User account under which bitcoind runs";
      };

      txindex = mkOption {
        default = false;
        description = ''
          Whether to reindex.
        '';
      };

      gen = mkOption {
        default = false;
        description = ''
          Whether to generate coins.
        '';
      };

      configFile = mkOption {
        type = types.path;
        default = confFile;
        defaultText = "confFile";
        example = literalExample ''pkgs.writeText "bitcoin.conf" "# my custom config file ..."'';
        description = ''
          Override the configuration file used by Bitcoind. By default,
          NixOS generates one automatically.
        '';
      };

    };

	};


  ###### implementation

  config = mkIf cfg.enable {

    users.extraUsers = optionalAttrs (cfg.user == "bitcoind") (singleton
      { name = "bitcoind";
        uid = config.ids.uids.bitcoind;
        description = "Bitcoind user";
      });

    environment.systemPackages = [ cfg.package ];

    systemd.services.bitcoind = {
      path = [ cfg.package ];

      after = [ "network.target" "display-manager.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = bitcoindCli;
        User = cfg.user;
      };
    };

  };

}
