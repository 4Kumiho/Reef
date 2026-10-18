import QtQuick

// Pulsante ✕ in alto a destra nelle finestre (.close)
Rectangle {
    id: c
    signal clicked()
    width: 44; height: 44; radius: 22
    color: "transparent"
    border.color: Theme.line2
    z: 5
    T { anchors.centerIn: parent; text: "✕"; font.pixelSize: 18; color: ma.containsMouse ? Theme.cream : Theme.white }
    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: c.clicked() }
}
