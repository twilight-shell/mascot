# twilight-shell/mascot

The mascot of the [twilight-shell](https://github.com/twilight-shell)
organization: Twilight lives in the bottom-right corner of the screen. She
breathes, strolls along the bottom edge, talks in a bubble (greetings, the hour,
the music that plays), dances to it and dozes off late at night. Click to poke
her, right-click for a menu, drag to pick her up and throw her. Hidden, she
peeks out from behind the right edge; click her to bring her back. It works on
its own or as a piece of the full shell.

## Requirements

[Quickshell](https://quickshell.org) 0.3 or newer, with
[twilight-shell/core](https://github.com/twilight-shell/core) installed. Music
comes from any MPRIS player.

## Sprites

The artwork isn't part of this repository. `scripts/get-sprites.sh` downloads
Twilight Sparkle's sprites from
[Desktop Ponies](https://github.com/RoosterDragon/Desktop-Ponies) (CC BY-NC-SA
3.0, see the credits there):

```sh
scripts/get-sprites.sh                  # to ~/.local/share/twilight-shell/mascot
scripts/get-sprites.sh ~/my-sprites     # or to a folder of your choice
```

The mascot reads one picture per mood from the folder: `idle`, `talk`, `happy`,
`dance`, `sleep`, `walk` and `drag`, as `.gif` or `.png`. A mood without a
picture uses `idle`; without `idle` she doesn't show up. Any set of pictures
works, so it can be another character. Point `sprites` in `mascot.toml` at the
folder.

## Running on its own

```sh
qs -p /path/to/mascot
qs -p /path/to/mascot ipc call mascot toggle        # hide her or bring her back
qs -p /path/to/mascot ipc call mascot say "hello"
```

If `Twilight.Core` is not in a directory Qt searches, point `QML_IMPORT_PATH` at
its parent directory.

## Using it in a shell

```sh
sudo make install        # to /usr/lib/qt6/qml/Twilight/Mascot
```

```qml
import Twilight.Mascot

Mascot { outputName: Compositor.focusedOutput }
```

| | |
|---|---|
| `outputName` | The output she lives on; the first screen when empty. The mascot doesn't know the compositor, so the host says which one. |

## Settings

`~/.config/twilight-shell/mascot.toml`, created with the defaults the first time
the mascot starts and applied as soon as it is saved:

```toml
# Show the mascot at all.
enabled = true

# Where her sprites are: idle.gif, talk.gif, happy.gif, dance.gif, sleep.gif,
# walk.gif and drag.gif (or .png). Without an idle sprite she doesn't show up.
# scripts/get-sprites.sh downloads a set.
sprites = "~/.local/share/twilight-shell/mascot"

# Dance to music that plays, and say what it is.
music = true

# Doze off late at night when nothing is going on.
sleep = true

# Minutes between unprompted remarks; 0 keeps her quiet.
chatter = 0
```

The colors come from `~/.config/twilight-shell/theme.toml` (see
[core](https://github.com/twilight-shell/core)).

## Credits

The sprites `scripts/get-sprites.sh` fetches are the work of the artists behind
[Desktop Ponies](https://github.com/RoosterDragon/Desktop-Ponies), a project by
RoosterDragon and many contributors. Thank you for drawing Twilight and for
sharing her under CC BY-NC-SA 3.0. The full list of artists is in their
[credits](https://github.com/RoosterDragon/Desktop-Ponies/blob/master/Content/credits.txt);
the script writes a `CREDITS.txt` with the same attribution next to the sprites.

My Little Pony: Friendship is Magic is © Hasbro. This project isn't affiliated
with or endorsed by Hasbro or Desktop Ponies.

## License

The code is MIT, see `LICENSE`. The sprites are not part of it: they keep their
own license, CC BY-NC-SA 3.0, which doesn't allow commercial use.
