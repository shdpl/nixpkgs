{ stdenv, buildGoPackage, fetchFromGitHub, pkgconfig, libvirt }:

buildGoPackage rec {
  version = "0.19.0";
  name = "kubevirt-${version}";

  src = fetchFromGitHub {
    owner = "kubevirt";
    repo = "kubevirt";
    rev = "v${version}";
    sha256 = "16alqflyd2iwpq865y8bprxrp1gszzdbj31fpg38m8dyhmyp4gi9";
  };

  goPackagePath = "kubevirt.io/kubevirt";

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libvirt ];

  meta = with stdenv.lib; {
    homepage = https://github.com/kubevirt/kubevirt;
    description = "Virtual Machine Management on Kubernetes";
    license = licenses.asl20;
  };
}
