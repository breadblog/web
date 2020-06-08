{ pkgs, name }:

with pkgs;

mkYarnPackage {
  name = "${name}-packages";
  packageJSON = ../package.json;
  patchPhase = ":";
  src = ../.;
  yarnLock = ../yarn.lock;
  publishBinsFor = ["webpack"];
}
