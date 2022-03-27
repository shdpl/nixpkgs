{ lib, stdenv, fetchFromGitHub, cmake, libarchive, boost, freeglut, libGLU, wxGTK31, zlib, pkg-config }:

stdenv.mkDerivation rec {
  pname = "rme";
  version = "3.7";

  src = fetchFromGitHub {
    owner = "hampusborgos";
    repo = "rme";
    rev = "v${version}";
    sha256 = "1wqgr7cg04xq3hdq0ikz6s2ir15aal1f9mrymq7kwh3c173v3zpd";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    libarchive
    boost
    freeglut
    libGLU
    wxGTK31
    zlib
  ];

  installPhase = ''
    cd .. # as cmake ends up in build/ directory, get out of there
    mkdir $out

    mkdir $out/bin
    cp build/rme $out/bin/rme

    cp -r brushes/ data/ extensions/ icons/ $out/
  '';

  meta = {
    description = "Map editor for top-down MMORPG set in a fantasy world";
    homepage = "http://github.com/hampusborgos/rme";
    license = lib.licenses.unfree;
  };
}
