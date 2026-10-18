import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

// Modifica (o creazione) di una voce del menu
Item {
    id: d
    property string formato: "wide"
    property bool bloccata: true
    property string voceId: ""
    readonly property var voce: voceId ? Store.drinkById(voceId) : null
    readonly property var base: voce || {
        categoria: Store.meCat !== "tutti" ? Store.meCat : (Store.menu.categorie[0] || {}).id,
        emoji: "🍺"
    }
    implicitHeight: col.implicitHeight + 26 + 22

    ListModel { id: righe }

    Component.onCompleted: {
        (base.varianti || []).forEach(function (x) {
            const o = typeof x === "string" ? { nome: x } : x;
            righe.append({ nome: o.nome || "", prezzo: Store.prezzoTxt(o.prezzo !== undefined && o.prezzo !== null ? o.prezzo : base.prezzo), info: o.info || "" });
        });
        Qt.callLater(function () { (d.voce ? prezzo : nome).forceActiveFocus() });
    }

    function aggiungiRiga() {
        righe.append({ nome: "", prezzo: "", info: "" });
        Qt.callLater(function () { rep.itemAt(righe.count - 1).primo.forceActiveFocus() });
    }
    function salva() {
        const lista = [];
        for (let k = 0; k < righe.count; k++) lista.push({ nome: righe.get(k).nome, prezzo: righe.get(k).prezzo, info: righe.get(k).info });
        salvaBtn.enabled = false;
        salvaBtn.text = "Salvo…";
        const e = Store.salvaVoce(d.voceId, {
            nome: nome.text, prezzo: prezzo.text, categoria: Store.menu.categorie[categoria.currentIndex].id,
            emoji: emoji.text, etichetta: etichetta.text, descrizione: descrizione.text
        }, lista);
        if (e) { salvaBtn.enabled = true; salvaBtn.text = "Salva"; err.text = e; return }
        Ui.chiudi(null);
    }
    function elimina() {
        if (eliminaBtn.tipo !== "fill") { eliminaBtn.tipo = "fill"; eliminaBtn.text = "Clicca ancora per eliminare"; return }
        const e = Store.eliminaVoce(d.voceId);
        if (e) { eliminaBtn.tipo = "danger"; eliminaBtn.text = "Elimina voce"; err.text = e; return }
        Ui.chiudi(null);
    }

    Chiudi { anchors { right: parent.right; top: parent.top; margins: 12 } onClicked: Ui.chiudi(null) }

    Column {
        id: col
        x: 24; y: 26
        width: d.width - 48

        T { text: d.voce ? "Modifica voce" : "Nuova voce"; font.pixelSize: 28; font.weight: Font.ExtraBold; font.letterSpacing: -0.28; bottomPadding: 8 }

        GridLayout {
            width: parent.width
            columns: 4
            columnSpacing: 12
            rowSpacing: 0
            Column {
                Layout.columnSpan: 2; Layout.fillWidth: true; Layout.preferredWidth: 2
                topPadding: 8; spacing: 8
                Etichetta { text: "Nome" }
                Campo { id: nome; width: parent.width; text: d.base.nome || ""; placeholderText: "es. Negroni"; onAccepted: d.salva() }
            }
            Column {
                Layout.fillWidth: true; Layout.preferredWidth: 1
                topPadding: 8; spacing: 8
                Etichetta { text: "Prezzo (€)" }
                Campo { id: prezzo; width: parent.width; decimale: true; text: Store.prezzoTxt(d.base.prezzo); placeholderText: "es. 8 oppure 4,50"; onAccepted: d.salva() }
            }
            Column {
                Layout.fillWidth: true; Layout.preferredWidth: 1
                topPadding: 8; spacing: 8
                Etichetta { text: "Categoria" }
                Scelta {
                    id: categoria
                    width: parent.width
                    model: Store.menu.categorie
                    textRole: "nome"
                    currentIndex: Math.max(0, Store.menu.categorie.findIndex(function (c) { return c.id === d.base.categoria }))
                }
            }
            Column {
                Layout.fillWidth: true; Layout.preferredWidth: 1
                topPadding: 16; spacing: 8
                Etichetta { text: "Icona" }
                Campo { id: emoji; width: parent.width; text: d.base.emoji || ""; placeholderText: "🍺"; maximumLength: 8; font.family: Theme.emoji; onAccepted: d.salva() }
            }
            Column {
                Layout.columnSpan: 2; Layout.fillWidth: true; Layout.preferredWidth: 2
                topPadding: 16; spacing: 8
                Etichetta { text: "Nome breve nel menu a tendina" }
                Campo { id: etichetta; width: parent.width; text: d.base.etichetta || ""; placeholderText: "Facoltativo (es. Spina)"; onAccepted: d.salva() }
            }
            Item { Layout.fillWidth: true; Layout.preferredWidth: 1 }
        }

        Column {
            width: parent.width
            topPadding: 16; spacing: 8
            Etichetta { text: "Ingredienti / descrizione" }
            TextArea {
                id: descrizione
                width: parent.width
                text: d.base.descrizione || ""
                placeholderText: "Facoltativa (es. Cotto, fontina, salsa a scelta)"
                wrapMode: TextEdit.Wrap
                font.family: Theme.font; font.pixelSize: 16; font.weight: Font.Medium
                color: Theme.white
                placeholderTextColor: Theme.placeholder
                selectionColor: Theme.cream; selectedTextColor: Theme.night
                leftPadding: 14; rightPadding: 14; topPadding: 12; bottomPadding: 12
                implicitHeight: Math.max(64, contentHeight + 24)
                background: Rectangle { radius: 10; color: Theme.night; border.color: descrizione.activeFocus ? Theme.cream : Theme.line2 }
            }
        }

        Item { width: 1; height: 26 }
        Sezione { width: parent.width; text: "Varianti" }
        T {
            width: parent.width; topPadding: 4
            wrapMode: Text.WordWrap; color: Theme.muted; font.pixelSize: 12; lineHeight: 1.4
            text: "Le scelte che compaiono quando aggiungi la voce a un tavolo (gusti dello spritz, piccola/media, panino/piadina/focaccia…). Prezzo vuoto = prezzo della voce."
        }
        Repeater {
            id: rep
            model: righe
            Item {
                property alias primo: rNome
                width: col.width
                height: rNome.implicitHeight + 8
                RowLayout {
                    y: 8
                    width: parent.width
                    height: rNome.implicitHeight
                    spacing: 6
                    Campo {
                        id: rNome
                        Layout.fillWidth: true; Layout.preferredWidth: 2
                        padding: 10; leftPadding: 12; rightPadding: 12; font.pixelSize: 15
                        placeholderText: "Nome (es. Aperol, Piadina)"
                        text: model.nome
                        onTextEdited: righe.setProperty(index, "nome", text)
                    }
                    Campo {
                        Layout.preferredWidth: 96
                        padding: 10; leftPadding: 12; rightPadding: 12; font.pixelSize: 15
                        decimale: true
                        placeholderText: "Prezzo"
                        text: model.prezzo
                        onTextEdited: righe.setProperty(index, "prezzo", text)
                    }
                    Campo {
                        Layout.fillWidth: true; Layout.preferredWidth: 2
                        padding: 10; leftPadding: 12; rightPadding: 12; font.pixelSize: 15
                        placeholderText: "Descrizione breve (facoltativa)"
                        text: model.info
                        onTextEdited: righe.setProperty(index, "info", text)
                    }
                    IconaBtn { Layout.fillHeight: true; text: "✕"; onClicked: righe.remove(index) }
                }
            }
        }
        Item { width: 1; height: 10 }
        Btn { small: true; text: "+ Aggiungi variante"; onClicked: d.aggiungiRiga() }

        T { id: err; width: parent.width; topPadding: 8; height: Math.max(28, implicitHeight); color: Theme.redHi; font.pixelSize: 14; wrapMode: Text.Wrap }
        Item { width: 1; height: 18 }
        RowLayout {
            width: parent.width
            spacing: 10
            Btn { id: eliminaBtn; visible: !!d.voce; Layout.fillWidth: true; Layout.preferredWidth: 1; tipo: "danger"; text: "Elimina voce"; onClicked: d.elimina() }
            Item { visible: !!d.voce; Layout.fillWidth: true; Layout.preferredWidth: 1 }
            Btn { Layout.fillWidth: true; Layout.preferredWidth: 1; text: "Annulla"; onClicked: Ui.chiudi(null) }
            Btn { id: salvaBtn; Layout.fillWidth: true; Layout.preferredWidth: 1; tipo: "primary"; text: "Salva"; onClicked: d.salva() }
        }
    }
}
