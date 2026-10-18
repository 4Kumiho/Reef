import QtQuick

// Titolo grande della pagina con sottotitolo e pulsante principale a destra (.page-title)
Item {
    id: p
    property string titolo: ""
    property string sub: ""
    property string pulsante: ""
    property string kbd: ""
    signal clicked()
    implicitHeight: Math.max(h.implicitHeight, b.implicitHeight) + 24

    T {
        id: h
        y: 4 + (b.implicitHeight - implicitHeight) / 2
        text: p.titolo
        font.pixelSize: 36; font.weight: Font.ExtraBold
        font.capitalization: Font.AllUppercase
        font.letterSpacing: -0.36
    }
    T {
        anchors { left: h.right; leftMargin: 14; baseline: h.baseline }
        text: p.sub
        color: Theme.muted
    }
    Btn {
        id: b
        y: 4
        anchors.right: parent.right
        visible: p.pulsante !== ""
        tipo: "primary"
        text: p.pulsante
        kbd: p.kbd
        onClicked: p.clicked()
    }
}
