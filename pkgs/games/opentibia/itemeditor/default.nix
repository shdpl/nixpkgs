{ lib, callPackage, buildGoModule, fetchFromGitLab, libotbm, dmd }:
buildGoModule {
  name = "opentibia-itemeditor";

  src = fetchFromGitLab {
    owner = "nawia";
    repo = "itemeditor";
    rev = "1823cab2fcf6bc89769311c3221b629e18cd68e7";
    sha256 = "sha256:04n380l9g94zmlzj5s0jzldj0wmnnrm3y6nwi3mj3shzc79h7jl8";
  };

  nativeBuildInputs = [ libotbm ];

  NIX_CFLAGS_COMPILE="-I${libotbm}/include";
  NIX_CFLAGS_LINK="-L${libotbm}/lib -lotbm -L${dmd}/lib -lphobos2";

  vendorSha256 = "sha256:0a2cp4lbirllxkdis1a462qhpmcva62zf8rchs6ra6ndladk48a9";

  meta = with lib; {
    homepage = "https://gitlab.com/nawia/itemeditor";
    description = "Item editor Top-down MMORPG set in a fantasy world";
  };
}
