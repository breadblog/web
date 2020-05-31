{ pkgs ? import ./nix/nixpkgs.nix {}
, env ? "dev"
}:

with pkgs;

let
  name =
    "blog-web";

in
mkShell {
  NODE_ENV = if env == "prod" then "production" else "development";
  LOCALE_ARCHIVE_2_27 = "${glibcLocales}/lib/locale/locale-archive";
  LOCALE_ARCHIVE_2_11 = "${glibcLocales}/lib/locale/locale-archive";
  LANG = "en_US.UTF-8";

  buildInputs = with elmPackages; [
    elm
    yarn
    nixops
    elm2nix
    elm-format
    elm-analyse
    nodejs-14_x
    glibcLocales
    elm-language-server
  ];
}

