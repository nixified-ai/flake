{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, tokenizers
}:

buildPythonPackage rec {
  pname = "rwkv";
  version = "0.7.3";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-pk1ouAxS7sTz/MWgFccEfZvvd2KwgQQCSEh2ICZU3ig=";
  };

  propagatedBuildInputs = [
    setuptools
    tokenizers
  ];

  pythonImportsCheck = [ "rwkv" ];

  meta = with lib; {
    description = "The RWKV Language Model";
    homepage = "https://github.com/BlinkDL/ChatRWKV";
    license = licenses.asl20;
    maintainers = with maintainers; [ jpetrucciani ];
  };
}
