import QtQuick

// Finestra con un messaggio e il pulsante OK
Item {
    id: d
    property string formato: "small"
    property string titolo: ""
    property string testo: ""
    implicitHeight: col.implicitHeight + 26 + 22
    Component.onCompleted: Qt.callLater(function () { okBtn.forceActiveFocus() })

    Column {
        id: col
        x: 24; y: 26
        width: d.width - 48
        T { width: parent.width; text: d.titolo; font.pixelSize: 28; font.weight: Font.ExtraBold; font.letterSpacing: -0.28; wrapMode: Text.Wrap; bottomPadding: 8 }
        T { width: parent.width; text: d.testo; textFormat: Text.StyledText; color: Theme.muted; lineHeight: 1.5; wrapMode: Text.Wrap; bottomPadding: 8 }
        Item { width: 1; height: 10 }
        Btn { id: okBtn; width: parent.width; tipo: "primary"; text: "OK"; onClicked: Ui.chiudi(null) }
    }
}
