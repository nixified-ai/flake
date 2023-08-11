# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ anyio, buildPythonPackage, fetchPypi, lib }:

buildPythonPackage rec {
  pname = "asyncer";
  version = "0.0.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0czlyysclcs1lyqh5j3a3ak05jb1jys5sfdldgqbmsr66rgwhinm";
  };

  propagatedBuildInputs = [ anyio ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "Asyncer, async and await, focused on developer experience.";
    homepage = "https://github.com/tiangolo/asyncer";
  };
}
