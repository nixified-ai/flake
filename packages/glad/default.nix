{ buildPythonPackage
, fetchFromGitHub
, lib
, jinja2
, cmake
}:

buildPythonPackage rec {
  pname = "glad";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = "Dav1dde";
    repo = "glad";
    rev = "v${version}";
    sha256 = "sha256-Sq7VUhRnGvHtVlLv1b7pyA+x8u3/cxNxxp5VBms0Vd0=";
  };

  propagatedBuildInputs = [ jinja2 ];
}
