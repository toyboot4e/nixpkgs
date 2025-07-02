{
  buildPythonPackage,
  darwin,
  fetchFromGitHub,
  lib,
  pyobjc-core,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyobjc-framework-Quartz";
  version = "11.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ronaldoussoren";
    repo = "pyobjc";
    tag = "v11.1";
    hash = "";
  };

  sourceRoot = "${src.name}/pyobjc-framework-Quartz";

  build-system = [ setuptools ];

  buildInputs = [
    darwin.libffi
    darwin.DarwinTools
  ];

  nativeBuildInputs = [
    darwin.DarwinTools # sw_vers
  ];

  dependencies = [ pyobjc-core ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-I${darwin.libffi.dev}/include"
    "-Wno-error=unused-command-line-argument"
  ];

  pythonImportsCheck = [ "Cocoa" ];

  meta = with lib; {
    description = "PyObjC wrappers for the Cocoa frameworks on macOS";
    homepage = "https://github.com/ronaldoussoren/pyobjc";
    license = licenses.mit;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ samuela ];
  };
}
