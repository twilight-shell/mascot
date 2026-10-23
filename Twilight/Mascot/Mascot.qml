import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Twilight.Core
import "parts"

// Twilight, living in the bottom-right corner. She breathes, blinks,
// strolls along the bottom edge, talks in a bubble (greetings, the hour,
// music), dances while something plays and dozes off late at night.
// Click to poke her, right-click for a menu, drag to pick her up and throw.
// Hidden, she peeks out from behind the right edge; click her to bring her back.
// Without sprites (see scripts/get-sprites.sh) she doesn't show up at all.
// The settings are in mascot.toml.
//
// IPC: `qs -c mascot ipc call mascot toggle`, `mascot say <text>`
PanelWindow {
    id: window

    // Name of the output she lives on; the first screen when empty or unknown.
    // The compositor is the host's business, so the host sets it.
    property string outputName: ""

    // `Number(...)` and `!!`: the defaults file is read a moment after the
    // first binding runs.
    readonly property bool enabled: !!config.get("enabled")
    readonly property bool music: !!config.get("music")
    readonly property bool nightSleep: !!config.get("sleep")
    // Minutes between unprompted remarks, 0 for none.
    readonly property real chatter: Number(config.get("chatter")) || 0
    readonly property string sprites: expand(config.get("sprites") ?? "")

    visible: enabled
    readonly property real floorY: height - pet.height - 10
    readonly property real homeX: width - pet.width - 40

    property bool hidden: false
    property bool sleeping: false
    // Dancing from the menu, on top of dancing to music.
    property bool forceDance: false
    readonly property bool dancing: (musicPlaying && music) || forceDance
    property bool happy: false
    property bool facingLeft: true

    readonly property var player: Mpris.players.values.find(p => p.isPlaying) ?? null
    readonly property bool musicPlaying: player !== null
    readonly property string track: player ? player.trackTitle : ""

    readonly property string mood: drag.active || airborne ? "drag"
        : sleeping ? "sleep"
        : happy ? "happy"
        : bubble.typing ? "talk"
        : stroll.running || walk.running ? "walk"
        : dancing ? "dance"
        : "idle"

    // Physics while thrown.
    property real vx: 0
    property real vy: 0
    property bool airborne: false
    property bool ready: false

    screen: Quickshell.screens.find(s => s.name === window.outputName) ?? Quickshell.screens[0]
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    // Only the mascot (and her menu when open) catch the pointer.
    mask: Region {
        item: pet

        Region {
            item: menuLoader
        }
    }

    WlrLayershell.namespace: "twilight-mascot"
    WlrLayershell.layer: WlrLayer.Top

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    function expand(path: string): string {
        return path.startsWith("~") ? Quickshell.env("HOME") + path.slice(1) : path;
    }

    function say(text) {
        if (hidden)
            return;
        sleeping = false;
        bubble.say(text);
    }

    function cheer() {
        happy = true;
        happyTimer.restart();
        hop.restart();
        const p = pet.mapToItem(sparks, pet.width / 2, 20);
        sparks.burst(p.x, p.y, 14);
    }

    function setHidden(value) {
        if (value === hidden)
            return;
        menuOpen = false;
        hidden = value;
        stroll.stop();
        // Hidden means peeking out from behind the right edge.
        petX.to = value ? width - pet.width * 0.3 : homeX;
        facingLeft = !value;
        walk.duration = Math.abs(pet.x - petX.to) * 4 + 200;
        walk.restart();
        if (!value)
            Qt.callLater(() => say("I'm back ✦"));
    }

    property bool menuOpen: false

    IpcHandler {
        target: "mascot"

        function toggle(): void {
            window.setHidden(!window.hidden);
        }

        function say(text: string): void {
            window.say(text);
        }
    }

    ConfigFile {
        id: config

        name: "mascot"
        defaults: Qt.resolvedUrl("mascot.defaults.toml")
    }

    Lines {
        id: lines
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes

        property int lastHour: -1

        onDateChanged: {
            const h = date.getHours();
            if (lastHour !== -1 && h !== lastHour)
                window.say(lines.chime(h));
            lastHour = h;
            // Doze off late at night when nothing is going on.
            if (window.nightSleep && h >= 1 && h < 6 && !window.musicPlaying && !bubble.open)
                window.sleeping = true;
        }
    }

    // Startup greeting once the shell has settled.
    Timer {
        running: true
        interval: 2500
        onTriggered: {
            window.ready = true;
            // Walk in from the right edge.
            petX.to = window.homeX;
            walk.duration = 1400;
            walk.restart();
            Qt.callLater(() => window.say(lines.greeting(clock.date.getHours())));
        }
    }

    onTrackChanged: {
        if (ready && track !== "" && window.music)
            say(lines.music(track, player?.trackArtist ?? ""));
    }

    // Unprompted remarks every few minutes, if she's allowed to chatter.
    Timer {
        running: window.ready && window.chatter > 0 && !window.hidden && !window.sleeping
        repeat: true
        interval: window.chatter * 60000
        onTriggered: window.say(lines.pick(lines.random))
    }

    Timer {
        id: happyTimer

        interval: 1400
        onTriggered: window.happy = false
    }

    // Wander a little along the bottom edge every now and then.
    Timer {
        running: window.ready && !window.hidden && !window.sleeping && !window.airborne && !drag.active
        repeat: true
        interval: 25000 + Math.random() * 20000
        onTriggered: {
            interval = 25000 + Math.random() * 20000;
            const target = Math.max(window.width * 0.55, Math.min(window.homeX, pet.x + (Math.random() - 0.5) * 500));
            window.facingLeft = target < pet.x;
            petX.to = target;
            walk.duration = Math.abs(pet.x - target) * 9 + 200;
            stroll.restart();
        }
    }

    // A walk: little hops while moving sideways.
    ParallelAnimation {
        id: stroll

        NumberAnimation { id: petX; target: pet; property: "x"; duration: walk.duration; easing.type: Easing.InOutSine }
        SequentialAnimation {
            loops: Math.max(1, Math.round(walk.duration / 260))

            NumberAnimation { target: pet; property: "lift"; to: 6; duration: 130; easing.type: Easing.OutQuad }
            NumberAnimation { target: pet; property: "lift"; to: 0; duration: 130; easing.type: Easing.InQuad }
        }
    }

    // Plain slide, used for hiding and coming back.
    NumberAnimation {
        id: walk

        target: pet
        property: "x"
        to: petX.to
        easing.type: Easing.InOutQuad

        // Peek back into the screen once behind the edge.
        onFinished: if (window.hidden) window.facingLeft = true
    }

    SequentialAnimation {
        id: hop

        NumberAnimation { target: pet; property: "lift"; to: 26; duration: 180; easing.type: Easing.OutQuad }
        NumberAnimation { target: pet; property: "lift"; to: 0; duration: 260; easing.type: Easing.OutBounce }
    }

    SequentialAnimation {
        id: squashAnim

        NumberAnimation { target: body; property: "squash"; to: 0.22; duration: 70 }
        NumberAnimation { target: body; property: "squash"; to: 0; duration: 420; easing.type: Easing.OutElastic }
    }

    // Throw physics: gravity, bouncy walls and floor.
    Timer {
        id: physics

        interval: 16
        repeat: true
        running: window.airborne
        onTriggered: {
            window.vy += 1.1;
            let x = pet.x + window.vx;
            let y = pet.y + window.vy;
            if (x < 0 || x > window.width - pet.width) {
                x = Math.max(0, Math.min(window.width - pet.width, x));
                window.vx = -window.vx * 0.6;
            }
            if (y < 0) {
                y = 0;
                window.vy = -window.vy * 0.5;
            }
            if (y >= window.floorY) {
                y = window.floorY;
                if (Math.abs(window.vy) > 4) {
                    window.vy = -window.vy * 0.45;
                    squashAnim.restart();
                } else {
                    window.vy = 0;
                    window.airborne = false;
                    window.vx = 0;
                    if (Math.random() < 0.6)
                        window.say(lines.pick(lines.landed));
                }
                window.vx *= 0.8;
            }
            pet.x = x;
            pet.alt = window.floorY - y;
            window.facingLeft = window.vx < 0 || (window.vx === 0 && window.facingLeft);
        }
    }

    Item {
        id: pet

        // Extra hop height on top of the resting position.
        property real lift: 0

        visible: body.hasSprites
        width: body.implicitWidth
        height: body.implicitHeight
        x: window.width + 40
        // Height above the floor.
        property real alt: 0

        y: window.floorY - alt
        rotation: window.airborne ? window.vx * 1.5 : 0

        Body {
            id: body

            y: -pet.lift
            spriteDir: window.sprites
            mood: window.mood
            talking: bubble.typing
            facingLeft: window.facingLeft
        }

        // Pick her up and throw.
        DragHandler {
            id: drag

            // Where on her she was grabbed, so she hangs from that point.
            property real grabX
            property real grabY
            property real lastX
            property real lastAlt

            target: null
            onActiveChanged: {
                if (active) {
                    window.hidden = false;
                    stroll.stop();
                    walk.stop();
                    window.airborne = false;
                    window.sleeping = false;
                    window.menuOpen = false;
                    grabX = centroid.scenePosition.x - pet.x;
                    grabY = centroid.scenePosition.y - pet.y;
                    lastX = pet.x;
                    lastAlt = pet.alt;
                } else {
                    window.airborne = true;
                }
            }
            onCentroidChanged: {
                if (!active)
                    return;
                lastX = pet.x;
                lastAlt = pet.alt;
                pet.x = centroid.scenePosition.x - grabX;
                pet.alt = window.floorY - (centroid.scenePosition.y - grabY);
                window.vx = Math.max(-40, Math.min(40, pet.x - lastX));
                window.vy = Math.max(-40, Math.min(40, lastAlt - pet.alt));
            }
        }

        TapHandler {
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onTapped: (point, button) => {
                if (window.hidden) {
                    window.setHidden(false);
                    return;
                }
                if (button === Qt.RightButton) {
                    window.menuOpen = !window.menuOpen;
                    return;
                }
                window.menuOpen = false;
                window.sleeping = false;
                window.cheer();
                window.say(Math.random() < 0.4 ? lines.pick(lines.poked) : lines.pick(lines.random));
            }
        }

        HoverHandler {
            cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        }
    }

    Floaters {
        anchors.fill: parent
        petX: pet.x
        petY: pet.y
        petWidth: pet.width
        sleeping: window.sleeping
        dancing: window.dancing
        visible: !window.hidden && !window.airborne
    }

    Bubble {
        id: bubble

        x: Math.max(8, Math.min(window.width - width - 8, pet.x + pet.width / 2 - width + 40))
        y: pet.y - height - 14
    }

    // Right-click menu
    Loader {
        id: menuLoader

        active: window.menuOpen
        x: Math.max(8, Math.min(window.width - width - 8, pet.x - width - 10))
        y: Math.max(8, pet.y + pet.height - height)

        sourceComponent: Menu {
            dancing: window.forceDance
            sleeping: window.sleeping
            onTalk: {
                window.menuOpen = false;
                window.say(lines.pick(lines.random));
            }
            onDanceToggled: {
                window.menuOpen = false;
                window.forceDance = !window.forceDance;
            }
            onNapToggled: {
                window.menuOpen = false;
                window.sleeping = !window.sleeping;
            }
            onHide: {
                window.menuOpen = false;
                window.setHidden(true);
            }
        }
    }

    SparkleBurst {
        id: sparks

        anchors.fill: parent
    }
}
