{ env ? "dev",
  isDev ? true
}:

let
  nixpkgs =
    import ./nix/nixpkgs.nix {};

  pkgs =
    import nixpkgs { config = {}; };

in

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

  buildInputs = builtins.concatLists [
    [
      semver-tool
      glibcLocales
    ]
    (if env == "ci" then [

    ] else if env == "dev" then with elmPackages; [
      elm
      yarn
      nixops
      elm2nix
      elm-format
      elm-analyse
      nodejs-14_x
      elm-language-server
    ] else [])
  ];
}

