import QtQuick

// Riquadro con un numero importante (incasso, tavoli, media…)
Rectangle {
    id: r
    property string etichetta: ""
    property string valore: ""
    property string nota: ""
    property bool principale: false
    implicitHeight: col.implicitHeight + 36
    radius: Theme.radius
    color: Theme.panel
    border.color: principale ? Theme.creamLine : Theme.line
    Column {
        id: col
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 18 }
        spacing: 6
        Caps { text: r.etichetta; color: r.principale ? Theme.cream : Theme.muted }
        T {
            width: parent.width
            text: r.valore
            font.pixelSize: r.principale ? 34 : 26
            font.weight: Font.ExtraBold
            elide: Text.ElideRight
        }
        T { width: parent.width; visible: r.nota !== ""; text: r.nota; color: Theme.muted; font.pixelSize: 13; elide: Text.ElideRight }
    }
}
