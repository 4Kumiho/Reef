import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

// Gestione del menu: prezzi, voci nuove, voci tolte, categorie
Column {
    id: v
    spacing: 0

    function focusRicerca() { ricerca.forceActiveFocus() }

    TitoloPagina {
        width: v.width
        titolo: "Menu"
        sub: { const agg = Store.dataMenu(); return Store.menu.drinks.length + " voci" + (agg ? " · aggiornato il " + agg : "") }
        pulsante: "+ Nuova voce"
        onClicked: Ui.apri("Editor", { voceId: "" })
    }

    Flow {
        width: v.width
        spacing: 8
        bottomPadding: 14
        Repeater {
            model: [
                { t: "Categorie", f: function () { Ui.apri("Categorie", {}) } },
                { t: "Scarica copia", f: function () { const doc = StandardPaths.writableLocation(StandardPaths.DocumentsLocation); salvaFile.currentFolder = doc; salvaFile.selectedFile = doc + "/" + Store.nomeEsportazione(); salvaFile.open() } },
                { t: "Carica copia", f: function () { apriFile.open() } },
                { t: "Ripristina originale", f: function () { Store.ripristinaMenu() } }
            ]
            Btn { small: true; implicitHeight: 42; text: modelData.t; onClicked: modelData.f() }
        }
    }

    Ricerca {
        id: ricerca
        width: v.width
        placeholderText: "Cerca una voce…  (tasto /)"
        text: Store.meQ
        onTextEdited: Store.meQ = text
        Keys.onEscapePressed: function (e) { if (text) { Store.meQ = ""; text = "" } else e.accepted = false }
    }

    Flow {
        width: v.width
        spacing: 8
        topPadding: 14; bottomPadding: 14
        Repeater {
            model: {
                Store.menu;
                const usate = Store.menu.categorie.filter(function (c) { return Store.menu.drinks.some(function (d) { return d.categoria === c.id }) });
                return [{ id: "tutti", nome: "Tutti" }].concat(usate);
            }
            Chip {
                text: modelData.nome
                on: Store.meQ.trim() === "" && modelData.id === Store.meCat
                onClicked: { Store.meCat = modelData.id; Store.meQ = ""; ricerca.text = "" }
            }
        }
    }

    AutoGrid {
        id: lista
        width: v.width
        minimo: 340; spazio: 8
        Repeater {
            id: voci
            model: { Store.menu; return Store.filtra(Store.menu.drinks, Store.meQ, Store.meCat) }
            Rectangle {
                id: riga
                implicitHeight: 66
                radius: Theme.radius
                color: ma.containsMouse ? Theme.panel2 : Theme.panel
                border.color: ma.containsMouse || ma.pressed ? Theme.line2 : Theme.line
                Tile {
                    id: tile
                    anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                    emoji: modelData.emoji || "🧾"
                    size: 40; fontSize: 19
                }
                Column {
                    anchors { left: tile.right; leftMargin: 12; right: prezzo.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
                    T { width: parent.width; text: modelData.nome; font.weight: Font.Bold; elide: Text.ElideRight }
                    T {
                        width: parent.width; topPadding: 3
                        font.pixelSize: 12; color: Theme.muted; elide: Text.ElideRight
                        text: {
                            const info = [Store.catNome(modelData.categoria)];
                            if (modelData.varianti && modelData.varianti.length) info.push(modelData.varianti.map(Store.varNome).join(", "));
                            else if (modelData.descrizione) info.push(modelData.descrizione);
                            return info.join(" · ");
                        }
                    }
                }
                T {
                    id: prezzo
                    anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                    text: Store.prezzoLabel(modelData)
                    color: Theme.cream; font.weight: Font.Bold
                }
                MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Ui.apri("Editor", { voceId: modelData.id }) }
            }
        }
    }
    Vuoto { width: v.width; visible: voci.count === 0; testo: "Nessuna voce trovata." }

    FileDialog {
        id: salvaFile
        title: "Scarica copia del menu"
        fileMode: FileDialog.SaveFile
        defaultSuffix: "json"
        nameFilters: ["Menu Reef (*.json)"]
        onAccepted: {
            if (backend.esporta(selectedFile.toString(), Store.testoEsportazione())) Ui.toast("Copia del menu salvata");
            else Ui.messaggio("Errore", "Non sono riuscito a salvare il file.");
        }
    }
    FileDialog {
        id: apriFile
        title: "Carica una copia del menu"
        fileMode: FileDialog.OpenFile
        nameFilters: ["Menu Reef (*.json)"]
        onAccepted: Store.importaMenu(backend.importa(selectedFile.toString()))
    }
}
