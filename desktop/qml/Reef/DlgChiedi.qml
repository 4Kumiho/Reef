import QtQuick
import QtQuick.Layouts

// Finestra con uno o più campi da compilare (nuovo tavolo, rinomina, voce libera)
Item {
    id: d
    property string formato: "small"
    property string titolo: ""
    property var campi: []
    property string ok: "OK"
    property var valida: null
    implicitHeight: col.implicitHeight + 26 + 22

    function valori() {
        const v = {};
        for (let k = 0; k < rep.count; k++) v[campi[k].name] = rep.itemAt(k).campo.text;
        return v;
    }
    function invia() {
        const v = valori();
        const e = valida ? valida(v) : "";
        if (e) { err.text = e; return }
        Ui.chiudi(v);
    }
    Component.onCompleted: Qt.callLater(function () {
        const c = rep.itemAt(0).campo;
        c.forceActiveFocus();
        c.selectAll();
    })

    Column {
        id: col
        x: 24; y: 26
        width: d.width - 48
        T { width: parent.width; text: d.titolo; font.pixelSize: 28; font.weight: Font.ExtraBold; font.letterSpacing: -0.28; wrapMode: Text.Wrap; bottomPadding: 8 }
        Repeater {
            id: rep
            model: d.campi
            Column {
                property alias campo: campo
                width: col.width
                topPadding: 8
                spacing: 8
                Etichetta { text: modelData.label }
                Campo {
                    id: campo
                    width: parent.width
                    text: modelData.value || ""
                    placeholderText: modelData.placeholder || ""
                    decimale: !!modelData.decimale
                    onAccepted: d.invia()
                }
            }
        }
        T { id: err; width: parent.width; topPadding: 8; height: Math.max(28, implicitHeight); color: Theme.redHi; font.pixelSize: 14; wrapMode: Text.Wrap }
        Item { width: 1; height: 18 }
        RowLayout {
            width: parent.width
            spacing: 10
            Btn { Layout.fillWidth: true; Layout.preferredWidth: 1; text: "Annulla"; onClicked: Ui.chiudi(null) }
            Btn { Layout.fillWidth: true; Layout.preferredWidth: 1; tipo: "primary"; text: d.ok; onClicked: d.invia() }
        }
    }
}
