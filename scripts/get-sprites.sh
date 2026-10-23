#!/bin/sh
# Downloads Twilight Sparkle sprites for the mascot from Desktop Ponies
# (https://github.com/RoosterDragon/Desktop-Ponies). The artwork is
# CC BY-NC-SA 3.0 by the Desktop Ponies artists, see their
# Content/credits.txt. It is not part of this repository.
#
#     get-sprites.sh [folder]
#
# The folder defaults to ~/.local/share/twilight-shell/mascot, where the mascot
# looks for them; point `sprites` in mascot.toml at another one if you use it.
set -e

dir="${1:-${XDG_DATA_HOME:-$HOME/.local/share}/twilight-shell/mascot}"
base="https://raw.githubusercontent.com/RoosterDragon/Desktop-Ponies/master/Content/Ponies/Twilight%20Sparkle"

mkdir -p "$dir"

# mood:file in Desktop Ponies
for pair in \
    idle:stand_twilight_left \
    talk:magic_twilight_left \
    happy:congatwilight_left \
    dance:twilight_partyhard_left \
    sleep:read \
    walk:twilight_trot_left \
    drag:twilightdrag_left
do
    mood="${pair%%:*}"
    file="${pair#*:}"
    echo "$mood <- $file.gif"
    curl -fsSL -o "$dir/$mood.gif" "$base/$file.gif"
done

cat > "$dir/CREDITS.txt" <<CREDITS
Twilight Sparkle sprites from Desktop Ponies
https://github.com/RoosterDragon/Desktop-Ponies

Artwork by the Desktop Ponies artists, licensed under CC BY-NC-SA 3.0
https://creativecommons.org/licenses/by-nc-sa/3.0/
Full credits: https://github.com/RoosterDragon/Desktop-Ponies/blob/master/Content/credits.txt

My Little Pony: Friendship is Magic is (c) Hasbro.
CREDITS

echo "Sprites installed to $dir"
