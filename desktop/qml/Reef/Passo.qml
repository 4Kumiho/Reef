import QtQuick

// Pulsante − / + delle quantità (.step button)
Item {
    id: p
    property string text: ""
    signal clicked()
    width: 42; height: 42
    T {
        anchors.centerIn: parent
        text: p.text
        font.pixelSize: 20
        color: ma.containsMouse ? Theme.cream : Theme.white
    }
    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: p.clicked() }
}
