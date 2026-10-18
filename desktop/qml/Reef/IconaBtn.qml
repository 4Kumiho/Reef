import QtQuick

// Piccolo pulsante quadrato delle righe modificabili (✕ togli, ↑ sposta su)
Rectangle {
    id: b
    property string text: ""
    signal clicked()
    implicitWidth: 44
    radius: 10
    color: "transparent"
    border.color: Theme.line
    opacity: enabled ? 1 : 0.35
    T {
        anchors.centerIn: parent
        text: b.text
        font.pixelSize: 16
        color: ma.containsMouse ? Theme.cream : Theme.muted
    }
    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: b.clicked() }
}
