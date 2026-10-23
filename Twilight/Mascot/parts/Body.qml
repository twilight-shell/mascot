import QtQuick
import Qt.labs.folderlistmodel

// The mascot's sprite for the current mood: <mood>.gif or <mood>.png from
// the sprite folder, falling back to idle. Sprites are scaled up by whole
// pixels and stand on the bottom edge of a box sized from the idle sprite,
// so switching moods doesn't shift her around. Squashes on landing.
Item {
    id: root

    property string mood: "idle"
    property bool talking: false
    property bool facingLeft: true
    property real squash: 0

    readonly property int pixel: 2
    // Folder with the sprites, an absolute path.
    property string spriteDir: ""
    property var available: []

    readonly property string idleFile: file("idle")
    readonly property string currentFile: file(mood) || (talking ? file("talk") : "") || idleFile
    readonly property bool hasSprites: idleFile !== ""

    implicitWidth: idleProbe.sourceSize.width * pixel
    implicitHeight: idleProbe.sourceSize.height * pixel

    function file(name) {
        for (const ext of [".gif", ".png"]) {
            if (available.includes(name + ext))
                return name + ext;
        }
        return "";
    }

    // Sprites can be added or changed while the shell runs.
    FolderListModel {
        folder: root.spriteDir !== "" ? "file://" + root.spriteDir : ""
        nameFilters: ["*.gif", "*.png"]
        showDirs: false
        onCountChanged: {
            const names = [];
            for (let i = 0; i < count; i++)
                names.push(get(i, "fileName"));
            root.available = names;
        }
    }

    // Only read for its size.
    Image {
        id: idleProbe

        visible: false
        source: root.idleFile !== "" ? "file://" + root.spriteDir + "/" + root.idleFile : ""
    }

    AnimatedImage {
        id: sprite

        source: root.currentFile !== "" ? "file://" + root.spriteDir + "/" + root.currentFile : ""
        width: sourceSize.width * root.pixel
        height: sourceSize.height * root.pixel
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        smooth: false
        playing: true

        transform: [
            // Landing squash, anchored at the feet.
            Scale {
                origin.x: sprite.width / 2
                origin.y: sprite.height
                xScale: 1 + root.squash
                yScale: 1 - root.squash
            },
            // Sprites face left; mirror when she faces right.
            Scale {
                origin.x: sprite.width / 2
                xScale: root.facingLeft ? 1 : -1
            }
        ]
    }
}
