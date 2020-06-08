{}: builtins.fetchGit {
  # Descriptive name to make the store path easier to identify
  name = "nixpkgs-unstable";
  url = "https://github.com/nixos/nixpkgs-channels/";
  # Commit hash for nixos-unstable as of 2020-05-27
  # `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`
  ref = "refs/heads/nixpkgs-unstable";
  rev = "571212eb839d482992adb05479b86eeb6a9c7b2f";
}
