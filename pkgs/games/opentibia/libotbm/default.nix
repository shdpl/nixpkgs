{ fetchFromGitHub, stdenv, lib, dmd }:
stdenv.mkDerivation {
  name = "libotbm";

  src = fetchFromGitHub {
    owner = "shdpl";
    repo = "libotbm";
    rev = "cinterface";
    sha256 = "111klaylalb89di6sgpnr79nczkg3gbz059f5cn96qd5h9vizh57";
  };
  nativeBuildInputs = [ dmd ];

  buildPhase = ''
    dmd -lib -release -O -H -Hdd/include/otbm src/otbm/common.d src/otbm/otb.d  src/otbm/otbm.d  src/otbm/parser.d -oflib/libotbm.a
  '';

  installPhase = ''
    mkdir $out
    cp -r lib $out
    cp -r include $out
    cp -r d $out
  '';

  meta = with lib; {
    homepage = "https://github.com/shdpl/libotbm";
    description = "Library for reading/writing .otbm and .otb formats ";
  };
}
