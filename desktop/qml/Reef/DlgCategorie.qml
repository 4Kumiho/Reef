import QtQuick
import QtQuick.Layouts

// Categorie del menu: rinomina, riordina con ↑, aggiungi; si elimina solo una categoria vuota
Item {
    id: d
    property string formato: "normal"
    property bool bloccata: true
    implicitHeight: col.implicitHeight + 26 + 22

    ListModel { id: righe }
    Component.onCompleted: {
        Store.menu.categorie.forEach(function (c) {
            righe.append({ cid: c.id, nome: c.nome, n: Store.menu.drinks.filter(function (x) { return x.categoria === c.id }).length });
        });
    }
    function aggiungi() {
        righe.append({ cid: "", nome: "", n: -1 });
        Qt.callLater(function () { rep.itemAt(righe.count - 1).campo.forceActiveFocus() });
    }
    function salva() {
        const lista = [];
        for (let k = 0; k < righe.count; k++) lista.push({ id: righe.get(k).cid, nome: righe.get(k).nome });
        const e = Store.salvaCategorie(lista);
        if (e) { err.text = e; return }
        Ui.chiudi(null);
    }

    Chiudi { anchors { right: parent.right; top: parent.top; margins: 12 } onClicked: Ui.chiudi(null) }

    Column {
        id: col
        x: 24; y: 26
        width: d.width - 48
        T { text: "Categorie"; font.pixelSize: 28; font.weight: Font.ExtraBold; font.letterSpacing: -0.28; bottomPadding: 8 }
        T {
            width: parent.width - 40; topPadding: 4
            wrapMode: Text.WordWrap; color: Theme.muted; font.pixelSize: 12; lineHeight: 1.4
            text: "Rinomina, riordina con ↑ o aggiungi categorie. Si può eliminare solo una categoria vuota."
        }
        Repeater {
            id: rep
            model: righe
            Item {
                property alias campo: campo
                width: col.width
                height: campo.implicitHeight + 8
                RowLayout {
                    y: 8
                    width: parent.width
                    height: campo.implicitHeight
                    spacing: 6
                    IconaBtn { Layout.fillHeight: true; text: "↑"; onClicked: if (index > 0) righe.move(index, index - 1, 1) }
                    Campo {
                        id: campo
                        Layout.fillWidth: true
                        padding: 10; leftPadding: 12; rightPadding: 12; font.pixelSize: 15
                        placeholderText: "Nome categoria"
                        text: model.nome
                        onTextEdited: righe.setProperty(index, "nome", text)
                        onAccepted: d.salva()
                    }
                    T {
                        Layout.preferredWidth: 54
                        horizontalAlignment: Text.AlignHCenter
                        text: model.n < 0 ? "nuova" : model.n + " voci"
                        color: Theme.muted; font.pixelSize: 12
                    }
                    IconaBtn { Layout.fillHeight: true; text: "✕"; enabled: model.n <= 0; onClicked: righe.remove(index) }
                }
            }
        }
        Item { width: 1; height: 10 }
        Btn { small: true; text: "+ Nuova categoria"; onClicked: d.aggiungi() }
        T { id: err; width: parent.width; topPadding: 8; height: Math.max(28, implicitHeight); color: Theme.redHi; font.pixelSize: 14; wrapMode: Text.Wrap }
        Item { width: 1; height: 18 }
        RowLayout {
            width: parent.width
            spacing: 10
            Btn { Layout.fillWidth: true; Layout.preferredWidth: 1; text: "Annulla"; onClicked: Ui.chiudi(null) }
            Btn { Layout.fillWidth: true; Layout.preferredWidth: 1; tipo: "primary"; text: "Salva"; onClicked: d.salva() }
        }
    }
}
