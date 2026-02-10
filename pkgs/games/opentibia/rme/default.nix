{ stdenv, fetchFromGitHub, cmake, wrapGAppsHook3, libarchive, boost186, fmt, freeglut, libGLU, nlohmann_json, wxGTK31, zlib }:

stdenv.mkDerivation {
  pname = "rme";
  version = "3.8-dev";

  src = fetchFromGitHub {
    owner = "hampusborgos";
    repo = "rme";
    rev = "da7152ec94031c76732e997de4624c8f1c010225";
    hash = "sha256-YyAhaRlRkkcP2nrkaW2HWMyPL8pWoqt2qAMittA7+3k=";
  };

  nativeBuildInputs = [ cmake wrapGAppsHook3 ];

  buildInputs = [
    libarchive
    boost186
    fmt
    freeglut
    libGLU
    nlohmann_json
    wxGTK31
    zlib
  ];

  patches = [
    ./rme.patch
  ];

  cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
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
  };
}
