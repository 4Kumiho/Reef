import QtQuick
import QtQuick.Layouts

// Dettaglio di un tavolo chiuso: cosa ha preso, quando ha pagato, quanto
Item {
    id: d
    property string formato: "normal"
    property var voce: null
    readonly property var prodotti: Cronologia.prodottiTavolo(voce)
    implicitHeight: col.implicitHeight + 26 + 22

    function elimina() {
        if (elBtn.tipo !== "fill") { elBtn.tipo = "fill"; elBtn.text = "Clicca ancora per eliminare"; return }
        if (Cronologia.elimina(d.voce.id)) { Ui.chiudi(null); Ui.toast("Tavolo «" + d.voce.nome + "» tolto dalla cronologia") }
        else { elBtn.tipo = "danger"; elBtn.text = "Elimina dalla cronologia"; err.text = "Non sono riuscito a modificare la cronologia." }
    }

    Chiudi { anchors { right: parent.right; top: parent.top; margins: 12 } onClicked: Ui.chiudi(null) }

    Column {
        id: col
        x: 24; y: 26
        width: d.width - 48
        T { width: parent.width - 48; text: d.voce.nome; font.pixelSize: 28; font.weight: Font.ExtraBold; elide: Text.ElideRight }
        T {
            width: parent.width; topPadding: 6
            color: Theme.muted
            text: Cronologia.etichettaSerata(Cronologia.serataDi(d.voce.aperto))
        }
        T {
            width: parent.width; bottomPadding: 14
            wrapMode: Text.WordWrap
            color: Theme.muted
            text: "aperto alle " + Qt.formatTime(new Date(d.voce.aperto), "HH:mm") + " · chiuso alle " + Qt.formatTime(new Date(d.voce.chiuso), "HH:mm")
                  + " · " + Cronologia.durata(d.voce.chiuso - d.voce.aperto)
        }

        Sezione { width: parent.width; text: "Ordine" }
        Repeater {
            model: d.prodotti
            Item {
                width: col.width; height: 40
                T { anchors.verticalCenter: parent.verticalCenter; width: parent.width - 200; text: modelData.nome; font.weight: Font.Bold; elide: Text.ElideRight }
                T { anchors { right: parent.right; rightMargin: 100; verticalCenter: parent.verticalCenter } text: modelData.qty + " × " + Store.euro(modelData.prezzoCent); color: Theme.muted; font.pixelSize: 13 }
                T { anchors { right: parent.right; verticalCenter: parent.verticalCenter } text: Store.euro(modelData.qty * modelData.prezzoCent); font.weight: Font.Bold }
                Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.line }
            }
        }
        Item {
            width: parent.width; height: totV.implicitHeight + 24
            Caps { anchors { left: parent.left; baseline: totV.baseline } text: "Totale"; dimensione: 12; color: Theme.muted }
            T { id: totV; anchors { right: parent.right; verticalCenter: parent.verticalCenter } text: Store.euro(Cronologia.totaleTavolo(d.voce)); font.pixelSize: 30; font.weight: Font.ExtraBold }
        }

        Item { width: 1; height: 6; visible: d.voce.incassi.length > 1 }
        Sezione { visible: d.voce.incassi.length > 1; width: parent.width; text: "Pagamenti" }
        Repeater {
            model: d.voce.incassi.length > 1 ? d.voce.incassi : []
            Item {
                width: col.width; height: 40
                T {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 120
                    elide: Text.ElideRight
                    text: Qt.formatTime(new Date(modelData.ts), "HH:mm") + " · " + modelData.righe.map(function (r) { return r.qty + "× " + r.nome }).join(", ")
                    color: Theme.muted; font.pixelSize: 13
                }
                T { anchors { right: parent.right; verticalCenter: parent.verticalCenter } text: Store.euro(modelData.cent); font.weight: Font.Bold }
            }
        }

        T { id: err; width: parent.width; topPadding: 8; height: Math.max(20, implicitHeight); color: Theme.redHi; font.pixelSize: 14; wrapMode: Text.Wrap }
        Item { width: 1; height: 10 }
        RowLayout {
            width: parent.width
            spacing: 10
            Btn { id: elBtn; Layout.fillWidth: true; Layout.preferredWidth: 1; tipo: "danger"; text: "Elimina dalla cronologia"; onClicked: d.elimina() }
            Btn { Layout.fillWidth: true; Layout.preferredWidth: 1; tipo: "primary"; text: "Chiudi"; onClicked: Ui.chiudi(null) }
        }
    }
}
