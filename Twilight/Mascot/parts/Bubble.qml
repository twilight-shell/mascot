import QtQuick
import Twilight.Core

// Speech bubble that types its text out and hides after a while.
Item {
    id: root

    property string text: ""
    property int shown: 0
    readonly property bool typing: typer.running
    readonly property bool open: pop > 0

    property real pop: 0

    // Sized from the full text so the bubble doesn't grow while typing.
    width: Math.min(300, full.width + 34)
    height: label.height + 26
    scale: pop
    opacity: Math.min(1, pop * 2)
    transformOrigin: Item.BottomRight

    function say(text) {
        root.text = text;
        shown = 0;
        hide.stop();
        popIn.restart();
        typer.restart();
    }

    NumberAnimation {
        id: popIn

        target: root
        property: "pop"
        to: 1
        duration: 420
        easing.type: Easing.OutBack
        easing.overshoot: 2.2
    }

    NumberAnimation {
        id: popOut

        target: root
        property: "pop"
        to: 0
        duration: 220
        easing.type: Easing.InBack
    }

    Timer {
        id: typer

        interval: 28
        repeat: true
        onTriggered: {
            root.shown++;
            if (root.shown >= root.text.length) {
                stop();
                hide.interval = 2400 + root.text.length * 45;
                hide.restart();
            }
        }
    }

    Timer {
        id: hide

        onTriggered: popOut.restart()
    }

    Sticker {
        anchors.fill: parent
        radius: 16
        lift: 4
        fill: Theme.surface
        edge: Theme.ink
    }

    // Tail pointing down-right at the mascot.
    Rectangle {
        x: parent.width - 42
        y: parent.height - 9
        width: 16
        height: 16
        rotation: 45
        color: Theme.surface
        border.color: Theme.ink
        border.width: 2

        Rectangle {
            x: -4
            y: -4
            width: 18
            height: 10
            rotation: -45
            color: Theme.surface
        }
    }

    TextMetrics {
        id: full

        font: label.font
        text: root.text
    }

    StyledText {
        id: label

        x: 16
        y: 13
        width: root.width - 32
        text: root.text.slice(0, root.shown)
        wrapMode: Text.Wrap
        font.pixelSize: 13
    }
}
