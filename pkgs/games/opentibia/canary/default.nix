{ stdenv, fetchFromGitHub, cmake, ninja, wrapGAppsHook3, asio_1_10, libarchive, boost186, fmt, freeglut, libGLU, nlohmann_json, protobuf_21, pugixml, spdlog, wxGTK33, xz, zlib }:

stdenv.mkDerivation {
  pname = "canary-map-editor";

  version = "opentibiabr-v4.0";
  src = fetchFromGitHub {
    owner = "opentibiabr";
    repo = "remeres-map-editor";
    rev = "v4.0";
    hash = "sha256-wibyuXqe9aYkwy7lam/1Rk0OKHf1elfFOo97M4QgkI0=";
  };

  nativeBuildInputs = [ cmake ninja wrapGAppsHook3 ];

  buildInputs = [
    asio_1_10
    libarchive
    boost186
    fmt
    freeglut
    libGLU
    nlohmann_json
    protobuf_21
    pugixml
    spdlog
    wxGTK33
    xz
    zlib
  ];

  patches = [
    ./canary.patch
  ];


  cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  installPhase = ''
        cd .. # as cmake ends up in build/ directory, get out of there
        mkdir $out

        mkdir $out/bin
        cp canary-map-editor $out/bin/canary-map-editor

        cp -r brushes/ data/ icons/ $out/
  '';

  meta = {
    description = "Map editor for top-down MMORPG set in a fantasy world";
    homepage = "https://github.com/opentibiabr/remeres-map-editor";
  };
}
