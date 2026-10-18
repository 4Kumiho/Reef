import QtQuick

// Pulsante (.btn): tipo "" | "primary" | "danger" | "fill" (rosso pieno)
Rectangle {
    id: b
    property string text: ""
    property string tipo: ""
    property bool small: false
    property string kbd: ""
    property real dimensione: small ? 11 : 12
    signal clicked()

    readonly property bool sopra: ma.containsMouse
    implicitHeight: small ? 40 : 48
    implicitWidth: riga.implicitWidth + (small ? 28 : 36) + 2
    radius: 10
    opacity: enabled ? 1 : 0.35
    scale: ma.pressed ? 0.97 : 1
    activeFocusOnTab: true
    color: tipo === "primary" ? (sopra ? Theme.creamHover : Theme.cream)
         : tipo === "fill" ? Theme.redHi
         : tipo === "danger" && sopra ? Theme.redSoft : "transparent"
    border.width: 1
    border.color: tipo === "primary" ? Theme.cream
                : tipo === "fill" ? Theme.redHi
                : tipo === "danger" ? Theme.redLine
                : sopra || activeFocus ? Theme.cream : Theme.line2
    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    Row {
        id: riga
        anchors.centerIn: parent
        spacing: 8
        Caps {
            anchors.verticalCenter: parent.verticalCenter
            text: b.text
            dimensione: b.dimensione
            spaziatura: 0.12
            color: b.tipo === "primary" ? Theme.night : b.tipo === "fill" ? "#ffffff" : b.tipo === "danger" ? Theme.redHi : Theme.white
        }
        Rectangle {
            visible: b.kbd !== ""
            anchors.verticalCenter: parent.verticalCenter
            width: k.implicitWidth + 12; height: k.implicitHeight + 2
            radius: 5; color: "transparent"; opacity: 0.65
            border.color: k.color
            T { id: k; anchors.centerIn: parent; text: b.kbd; font.pixelSize: 11; color: b.tipo === "primary" ? Theme.night : Theme.white }
        }
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: b.clicked()
    }
    Keys.onReturnPressed: b.clicked()
    Keys.onEnterPressed: b.clicked()
    Keys.onSpacePressed: b.clicked()
}
