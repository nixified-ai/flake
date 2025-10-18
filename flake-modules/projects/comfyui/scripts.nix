{
  lib,
  fetchFromGitHub,
  python3Packages,
  stdenv,
  writeShellApplication,
}:
rec {
  getRepoOwnerList =
    packages:
    map
      (
        { name, value }:
        {
          inherit (value.src) repo owner;
          inherit name;
        }
      )
      (
        lib.filter (
          { value, ... }:
          let
            x = value;
            b = x ? src && x.src ? owner;
          in
          if b then b else (builtins.trace x.name b)
        ) (lib.attrsToList packages)
      );

  packagesNoOwner = packages: map (x: x.name) (lib.filter (x: !(x ? src && x.src ? owner)) packages);

  add-npins-src-github = writeShellApplication {
    text = builtins.readFile ./scripts/add-npins-src-github.sh;
    name = "add-npins-src-github";
    runtimeInputs = [
      github-get-default-branch
    ];
  };
  github-get-default-branch = writeShellApplication {
    text = builtins.readFile ./scripts/github-get-default-branch.sh;
    name = "github-get-default-branch";
  };
  make-add-github-sources =
    packages:
    writeShellApplication {
      name = "add-github-sources";
      text =
        let
          commands = map (
            {
              repo,
              owner,
              name,
            }:
            ''${lib.getExe add-npins-src-github} ${
              lib.escapeShellArgs [
                owner
                repo
                name
              ]
            }''
          ) (getRepoOwnerList packages);
        in
        ''
          ${lib.concatStringsSep "\n" commands}
        '';
    };

}
