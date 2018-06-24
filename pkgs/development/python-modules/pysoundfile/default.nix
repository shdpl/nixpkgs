{ lib
, buildPythonPackage
, fetchPypi
, pytest
, numpy
, libsndfile
, cffi
, isPyPy
, stdenv
}:

buildPythonPackage rec {
  pname = "PySoundFile";
  version = "0.9.0.post1";
  name = pname + "-" + version;

  src = fetchPypi {
    inherit pname version;
    sha256 = "43dd46a2afc0484c26930a7e59eef9365cee81bce7a4aadc5699f788f60d32c3";
  };

    checkInputs = [ pytest ];
    propagatedBuildInputs = [ numpy libsndfile cffi ];

    meta = {
      description = "An audio library based on libsndfile, CFFI and NumPy";
      license = lib.licenses.bsd3;
      homepage = https://github.com/bastibe/PySoundFile;
      maintainers = with lib.maintainers; [ fridh ];
    };

    prePatch = ''
      substituteInPlace soundfile.py --replace "'sndfile'" "'${libsndfile.out}/lib/libsndfile.so'"
    '';

    # https://github.com/bastibe/PySoundFile/issues/157
    disabled = isPyPy ||  stdenv.isi686;
}
