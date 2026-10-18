import QtQuick

// Filtro a pillola (.chip)
Rectangle {
    id: c
    property string text: ""
    property bool on: false
    signal clicked()
    implicitWidth: t.implicitWidth + 34
    implicitHeight: t.implicitHeight + 20
    radius: height / 2
    color: on ? Theme.cream : "transparent"
    border.color: on ? Theme.cream : ma.containsMouse ? Theme.line2 : Theme.line
    T {
        id: t
        anchors.centerIn: parent
        text: c.text
        font.pixelSize: 13
        font.weight: c.on ? Font.Bold : Font.DemiBold
        font.letterSpacing: 0.26
        color: c.on ? Theme.night : ma.containsMouse ? Theme.white : Theme.muted
    }
    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: c.clicked() }
}
