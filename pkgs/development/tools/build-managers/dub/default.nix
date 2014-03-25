{ stdenv, fetchurl, curl, dmd, git }:

let version = "0.9.21"; in
stdenv.mkDerivation {
	name = "dub-${version}";

	src = fetchurl {
		url = https://codeload.github.com/rejectedsoftware/dub/tar.gz/v${version};
		sha256 = "cd90174b3f4d14500ed7a971059792fbaf9203df6c59c4ad25aaf8afdaa83c72";
	};

	unpackPhase = "tar xzf $src";

	buildInputs = [ curl dmd git ];

	buildPhase = "cd dub-${version} && ./build.sh";

	installPhase = "mkdir -p $out/bin && mv bin/dub $out/bin";

	meta = with stdenv.lib; {
		description = "D language build tool";
		longDescription = 
			''DUB is a build tool for D projects with support for automatically
				retrieving dependencies and integrating them in the build process.
				The design emphasis is on maximum simplicity for simple projects,
				while providing the opportunity to customize things when needed.
			'';
		homepage = http://code.dlang.org/;
		license = licenses.mit;
		platforms = platforms.unix;
	};
}
