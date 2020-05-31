{ pkgs ? import ./nix/nixpkgs.nix {}
, env ? "prod"
}:

with pkgs;

let
  name = "blog-web";

  yarnPkg =
    import ./nix/yarnpkgs.nix { inherit pkgs name; };

in stdenv.mkDerivation {
  WEBPACK_ENV = env;
  NODE_ENV = if env == "prod" then "production" else "development";
  LOCALE_ARCHIVE_2_27 = "${glibcLocales}/lib/locale/locale-archive";
  LOCALE_ARCHIVE_2_11 = "${glibcLocales}/lib/locale/locale-archive";
  LANG = "en_US.UTF-8";

  inherit name;

  src = nix-gitignore.gitignoreSource [] ./.;

  buildInputs = with elmPackages; [
    elm
    yarn
    yarnPkg
    elm2nix
    elm-test
    elm-format
    elm-analyse
    nodejs-14_x
    glibcLocales
  ];

  # TODO: add tests

  patchPhase = ''
    ln -sf ${yarnPkg}/libexec/${name}/node_modules .
  '';

  configurePhase = elmPackages.fetchElmDeps {
    elmVersion = "0.19.1";
    elmPackages = import ./elm-srcs.nix;
    registryDat = ./registry.dat;
  };

  installPhase = ''
    mkdir -p $out
    yarn test
    webpack
    mv ./dist $out/www
  '';
}
