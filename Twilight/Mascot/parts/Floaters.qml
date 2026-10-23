import QtQuick
import Twilight.Core

// Floating ♪ while dancing, z while asleep, rising from the mascot.
Item {
    id: root

    // Where the mascot stands, in this item's coordinates.
    property real petX: 0
    property real petY: 0
    property real petWidth: 0
    property bool sleeping: false
    property bool dancing: false

    Repeater {
        model: 3

        Text {
            id: floater

            required property int index

            // 0 -> 1 rising and fading, staggered per floater; driven by the
            // 30 Hz ticker so the full-screen window isn't redrawn at 144.
            readonly property real t: ((Ticker.t + index * 0.6) % 1.8) / 1.8

            visible: root.dancing || root.sleeping
            x: root.petX + root.petWidth * (root.sleeping ? 0.7 : 0.2 + index * 0.3) + Math.sin(t * 6 + index) * 8
            y: root.petY - 10 - t * 60
            opacity: 1 - t
            text: root.sleeping ? "z" : (index % 2 ? "♪" : "♫")
            color: root.sleeping ? Theme.primary : Theme.star
            font.family: Theme.font
            font.pixelSize: 14 + index * 4
            font.bold: true
            style: Text.Outline
            styleColor: Theme.ink
        }
    }
}
