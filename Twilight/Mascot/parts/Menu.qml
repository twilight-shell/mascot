import QtQuick
import Twilight.Core

// The right-click menu: a few stickers that pop up from the mascot.
Sticker {
    id: root

    property bool dancing: false
    property bool sleeping: false

    signal talk
    signal danceToggled
    signal napToggled
    signal hide

    property real pop: 0

    width: 170
    height: column.implicitHeight + 16
    radius: 16
    lift: 5
    fill: Theme.surface
    scale: pop
    transformOrigin: Item.BottomRight
    Component.onCompleted: popIn.start()

    NumberAnimation {
        id: popIn

        target: root
        property: "pop"
        from: 0
        to: 1
        duration: 380
        easing.type: Easing.OutBack
        easing.overshoot: 2
    }

    Column {
        id: column

        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: [
                { label: "✦ Talk to me", action: () => root.talk() },
                { label: root.dancing ? "♪ Stop dancing" : "♪ Dance", action: () => root.danceToggled() },
                { label: root.sleeping ? "☀ Wake up" : "☾ Nap time", action: () => root.napToggled() },
                { label: "✧ Hide", action: () => root.hide() }
            ]

            Tap {
                required property var modelData

                width: 150
                height: 30
                radius: 10
                lift: 2
                fill: Theme.surfaceHigh
                hoverFill: Theme.secondary
                onClicked: modelData.action()

                StyledText {
                    x: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.label
                    font.pixelSize: 12
                }
            }
        }
    }
}
