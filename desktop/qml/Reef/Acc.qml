import QtQuick

// Riquadro a fisarmonica del menu del tavolo (.acc): livello "gruppo", "sub" (categoria) o "ter" (voce)
Rectangle {
    id: a
    property string titolo: ""
    property int conteggio: 0
    property bool aperto: false
    property string livello: "gruppo"
    property Component corpo: null
    signal toggle()

    height: testa.height + (aperto && body.item ? body.item.height + 12 : 0)
    radius: 12
    color: livello === "sub" ? Theme.panel : Theme.panel2
    border.color: aperto ? Theme.line2 : Theme.line

    Item {
        id: testa
        width: parent.width
        height: a.livello === "gruppo" ? 56 : a.livello === "sub" ? 48 : 46
        readonly property real lato: a.livello === "gruppo" ? 16 : 14
        T {
            id: nome
            anchors { left: parent.left; leftMargin: testa.lato; right: cnt.left; rightMargin: 12; verticalCenter: parent.verticalCenter }
            text: a.titolo
            elide: Text.ElideRight
            font.pixelSize: a.livello === "gruppo" ? 17 : 14
            font.weight: a.livello === "gruppo" ? Font.ExtraBold : Font.Bold
            font.capitalization: a.livello === "gruppo" ? Font.AllUppercase : Font.MixedCase
            font.letterSpacing: a.livello === "gruppo" ? 0.34 : 0
            color: a.aperto || ma.containsMouse ? Theme.cream : Theme.white
        }
        T {
            id: cnt
            anchors { right: chev.left; rightMargin: 12; verticalCenter: parent.verticalCenter }
            text: a.conteggio
            font.pixelSize: 12
            color: Theme.muted
        }
        T {
            id: chev
            anchors { right: parent.right; rightMargin: testa.lato; verticalCenter: parent.verticalCenter; verticalCenterOffset: -2 }
            text: "›"
            font.pixelSize: 24
            color: a.aperto ? Theme.cream : Theme.muted
            rotation: a.aperto ? 90 : 0
            Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        }
        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: a.toggle() }
    }
    Loader {
        id: body
        active: a.aperto
        y: testa.height
        x: 10
        width: a.width - 20
        sourceComponent: a.corpo
    }
}
