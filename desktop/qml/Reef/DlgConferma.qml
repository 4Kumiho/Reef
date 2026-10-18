import QtQuick
import QtQuick.Layouts

// Finestra di conferma (chiudi tavolo, tavolo saldato…)
Item {
    id: d
    property string formato: "small"
    property string titolo: ""
    property string testo: ""
    property string ok: "Conferma"
    property bool pericolo: false
    implicitHeight: col.implicitHeight + 26 + 22
    Component.onCompleted: Qt.callLater(function () { conf.forceActiveFocus() })

    Column {
        id: col
        x: 24; y: 26
        width: d.width - 48
        T { width: parent.width; text: d.titolo; font.pixelSize: 28; font.weight: Font.ExtraBold; font.letterSpacing: -0.28; wrapMode: Text.Wrap; bottomPadding: 8 }
        T { width: parent.width; text: d.testo; textFormat: Text.StyledText; color: Theme.muted; lineHeight: 1.5; wrapMode: Text.Wrap; bottomPadding: 8 }
        Item { width: 1; height: 10 }
        RowLayout {
            width: parent.width
            spacing: 10
            Btn { Layout.fillWidth: true; Layout.preferredWidth: 1; text: "Annulla"; onClicked: Ui.chiudi(null) }
            Btn { id: conf; Layout.fillWidth: true; Layout.preferredWidth: 1; tipo: d.pericolo ? "fill" : "primary"; text: d.ok; onClicked: Ui.chiudi(true) }
        }
    }
}
