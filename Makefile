.PHONY: build
build:
	- nix-build

.PHONY: bump
bump:
	- nix-shell \
	    --arg env \"ci\" \
	    --run "./scripts/update-commit $$PWD/COMMIT"
	- nix-shell \
	    --arg env \"ci\" \
	    --run "./scripts/bump-version $$PWD/VERSION"
	- nix-shell \
	    --arg env \"ci\" \
	    --run "./scripts/propagate-version $$PWD/VERSION $$PWD/src/Version.elm $$PWD/package.json"
