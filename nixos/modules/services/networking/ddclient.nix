{ config, pkgs, lib, ... }:

let

  inherit (lib) mkOption mkIf singleton;
  inherit (pkgs) ddclient;

  stateDir = "/var/spool/ddclient";
  ddclientUser = "ddclient";
  ddclientFlags = "-foreground -verbose -noquiet -file ${config.services.ddclient.configFile}";
  ddclientPIDFile = "${stateDir}/ddclient.pid";

in

{

  ###### interface

  options = {

    services.ddclient = with lib.types; {

      enable = mkOption {
        default = false;
        type = bool;
        description = ''
          Whether to synchronise your machine's IP address with a dynamic DNS provider (e.g. dyndns.org).
        '';
      };

      domain = mkOption {
        default = "";
        type = str;
        description = ''
          Domain name to synchronize.
        '';
      };

      username = mkOption {
        default = "";
        type = str;
        description = ''
          Username.
        '';
      };

      password = mkOption {
        default = "";
        type = str;
        description = ''
          Password. WARNING: The password becomes world readable in the Nix store.
        '';
      };

      configFile = mkOption {
        default = "/etc/ddclient.conf";
        type = path;
        description = ''
          Path to configuration file.
          When set to the default '/etc/ddclient.conf' it will be populated with the various other options in this module. When it is changed (for example: '/root/nixos/secrets/ddclient.conf') the file read directly to configure ddclient. This is a source of impurity.
          The purpose of this is to avoid placing secrets into the store.
        '';
        example = "/root/nixos/secrets/ddclient.conf";
      };

      protocol = mkOption {
        default = "dyndns2";
        type = str;
        description = ''
          Protocol to use with dynamic DNS provider (see http://sourceforge.net/apps/trac/ddclient/wiki/Protocols).
        '';
      };

      server = mkOption {
        default = "";
        type = str;
        description = ''
          Server address.
        '';
      };

      ssl = mkOption {
        default = true;
        type = bool;
        description = ''
          Whether to use to use SSL/TLS to connect to dynamic DNS provider.
        '';
      };

      extraConfig = mkOption {
        default = "";
        type = lines;
        description = ''
          Extra configuration. Contents will be added verbatim to the configuration file.
        '';
      };

      use = mkOption {
        default = "web, web=checkip.dyndns.com/, web-skip='Current IP Address: '";
        type = str;
        description = ''
          Method to determine the IP address to send to the dynamic DNS provider.
        '';
      };
    };
  };


  ###### implementation

  config = mkIf config.services.ddclient.enable {

    environment.systemPackages = [ ddclient ];

    users.extraUsers = singleton {
      name = ddclientUser;
      uid = config.ids.uids.ddclient;
      description = "ddclient daemon user";
      home = stateDir;
    };

    environment.etc."ddclient.conf" = {
      enable = config.services.ddclient.configFile == "/etc/ddclient.conf";
      uid = config.ids.uids.ddclient;
      mode = "0600";
      text = ''
        # This file can be used as a template for configFile or is automatically generated by Nix options.
        daemon=600
        cache=${stateDir}/ddclient.cache
        pid=${ddclientPIDFile}
        use=${config.services.ddclient.use}
        login=${config.services.ddclient.username}
        password=${config.services.ddclient.password}
        protocol=${config.services.ddclient.protocol}
        server=${config.services.ddclient.server}
        ssl=${if config.services.ddclient.ssl then "yes" else "no"}
        wildcard=YES
        ${config.services.ddclient.domain}
        ${config.services.ddclient.extraConfig}
      '';
    };

    systemd.services.ddclient = {
      description = "Dynamic DNS Client";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      restartTriggers = [ config.environment.etc."ddclient.conf".source ];

      serviceConfig = {
        # Uncomment this if too many problems occur:
        # Type = "forking";
        User = ddclientUser;
        Group = "nogroup"; #TODO get this to work
        PermissionsStartOnly = "true";
        PIDFile = ddclientPIDFile;
        ExecStartPre = ''
          ${pkgs.stdenv.shell} -c "${pkgs.coreutils}/bin/mkdir -m 0755 -p ${stateDir} && ${pkgs.coreutils}/bin/chown ${ddclientUser} ${stateDir}"
        '';
        ExecStart = "${ddclient}/bin/ddclient ${ddclientFlags}";
        #ExecStartPost = "${pkgs.coreutils}/bin/rm -r ${stateDir}"; # Should we have this?
      };
    };
  };
}
