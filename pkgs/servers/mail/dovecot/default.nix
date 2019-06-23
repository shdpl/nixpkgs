{ stdenv, lib, fetchurl, fetchpatch, perl, pkgconfig, systemd, openssl
, bzip2, zlib, lz4, inotify-tools, pam, libcap
, clucene_core_2, icu, openldap, libsodium, libstemmer
# Auth modules
, withMySQL ? false, mysql
, withPgSQL ? false, postgresql
, withSQLite ? true, sqlite
}:

stdenv.mkDerivation rec {
  name = "dovecot-2.3.4.1";

  nativeBuildInputs = [ perl pkgconfig ];
  buildInputs =
    [ openssl bzip2 zlib lz4 clucene_core_2 icu openldap libsodium libstemmer ]
    ++ lib.optionals (stdenv.isLinux) [ systemd pam libcap inotify-tools ]
    ++ lib.optional withMySQL mysql.connector-c
    ++ lib.optional withPgSQL postgresql
    ++ lib.optional withSQLite sqlite;

  src = fetchurl {
    url = "https://dovecot.org/releases/2.3/${name}.tar.gz";
    sha256 = "01xa8d08c0j51w5kmqb3vnzrvh17hkzx5a5p7fb5hgn3wln3x1xq";
  };

  preConfigure = ''
    patchShebangs src/config/settings-get.pl
  '';

  # We need this for sysconfdir, see remark below.
  installFlags = [ "DESTDIR=$(out)" ];

  postInstall = ''
    cp -r $out/$out/* $out
    rm -rf $out/$(echo "$out" | cut -d "/" -f2)
  '' + lib.optionalString stdenv.isDarwin ''
    install_name_tool -change libclucene-shared.1.dylib \
        ${clucene_core_2}/lib/libclucene-shared.1.dylib \
        $out/lib/dovecot/lib21_fts_lucene_plugin.so
    install_name_tool -change libclucene-core.1.dylib \
        ${clucene_core_2}/lib/libclucene-core.1.dylib \
        $out/lib/dovecot/lib21_fts_lucene_plugin.so
  '';

  patches = [
    # Make dovecot look for plugins in /etc/dovecot/modules
    # so we can symlink plugins from several packages there.
    # The symlinking needs to be done in NixOS.
    ./2.2.x-module_dir.patch

    (fetchpatch {
      name = "CVE-2019-7524.patch";
      url = https://github.com/dovecot/core/compare/578cf77e84b3d25e2f95f08133a2b0b212aa77cc~1..696320b0f3644e928a9d0c71c063f603c3792dbb.patch;
      sha256 = "101d757gid0dn3mxqqpa59igkgkq7bwffsklh3nimaav0v2zb018";
    })
    (fetchpatch {
      name = "CVE-2019-10691.patch";
      url = https://github.com/dovecot/core/commit/973769d74433de3c56c4ffdf4f343cb35d98e4f7.patch;
      sha256 = "1rp0nfq2qkrx59l6rf8i0v3a8svijmkpnimcpa7vz3b93krk50bp";
    })
  ];

  configureFlags = [
    # It will hardcode this for /var/lib/dovecot.
    # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=626211
    "--localstatedir=/var"
    # We need this so utilities default to reading /etc/dovecot/dovecot.conf file.
    "--sysconfdir=/etc"
    "--with-ldap"
    "--with-ssl=openssl"
    "--with-zlib"
    "--with-bzlib"
    "--with-lz4"
    "--with-ldap"
    "--with-lucene"
    "--with-icu"
  ] ++ lib.optional (stdenv.isLinux) "--with-systemdsystemunitdir=$(out)/etc/systemd/system"
    ++ lib.optional (stdenv.isDarwin) "--enable-static"
    ++ lib.optional withMySQL "--with-mysql"
    ++ lib.optional withPgSQL "--with-pgsql"
    ++ lib.optional withSQLite "--with-sqlite";

  meta = {
    homepage = https://dovecot.org/;
    description = "Open source IMAP and POP3 email server written with security primarily in mind";
    maintainers = with stdenv.lib.maintainers; [ peti rickynils fpletz ];
    platforms = stdenv.lib.platforms.unix;
  };
}
