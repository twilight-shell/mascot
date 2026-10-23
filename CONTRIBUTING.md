# Contributing to mascot

Thank you for helping. The guide for every repository of the organization is [here](https://github.com/twilight-shell/.github/blob/main/CONTRIBUTING.md): how to propose a change, the commit messages, the checks and the code style. What follows is what is particular to this repository.

## Working on it

- **What it needs:** Twilight.Core. Clone them next to this one and put their parent folders on `QML_IMPORT_PATH`, separated by `:`, as full paths (not `~`).
- **Run it:** `XDG_CONFIG_HOME=$(mktemp -d) QML_IMPORT_PATH=$HOME/src/core:$HOME/src/mascot qs -p .` (the first part keeps your real settings out of it). `qs -p . ipc call mascot toggle` hides her and `mascot say "hello"` makes her talk; she needs the sprites to show up.
- **Tests:** there is no test for the screen: run it and look, and say in the pull request what you tried and on which compositor.
- **Before sending:** run the checks of the guide (`ci/run-tests.sh`, `check-settings.sh`, `check-depends.sh`, `check-install.sh` from the `.github` repository) and add a line to `CHANGELOG.md` under `## Unreleased`.

## Good to know

- **Don't commit sprites.** The artwork has its own license (CC BY-NC-SA) and isn't ours; the script fetches it and writes the credits.

For security problems, please don't open an issue: see [SECURITY.md](https://github.com/twilight-shell/.github/blob/main/SECURITY.md).
