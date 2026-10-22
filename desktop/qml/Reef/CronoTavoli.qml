import QtQuick

// Cronologia → Tavoli chiusi, raggruppati per serata (anche quelli già chiusi da tempo)
Column {
    id: v
    spacing: 0
    readonly property var gruppi: { Cronologia.rev; Cronologia.tipo; Cronologia.rif; Cronologia.cerca; return Cronologia.gruppiTavoli() }
    readonly property int aperti: { Store.rev; return Store.tavoli.length }

    function focusRicerca() { ricerca.forceActiveFocus() }

    Ricerca {
        id: ricerca
        width: v.width
        placeholderText: "Cerca un tavolo o un prodotto…  (tasto /)"
        text: Cronologia.cerca
        onTextEdited: Cronologia.cerca = text
        Keys.onEscapePressed: function (e) { if (text) { Cronologia.cerca = ""; text = "" } else e.accepted = false }
    }
    T {
        visible: v.aperti > 0
        topPadding: 12
        text: v.aperti + " " + Store.plurale(v.aperti, "tavolo è ancora aperto: compare qui", "tavoli sono ancora aperti: compaiono qui") + " quando lo chiudi."
        color: Theme.muted; font.pixelSize: 13
    }
    Item { width: 1; height: 16 }

    Vuoto {
        width: v.width
        visible: v.gruppi.length === 0
        icona: "🕰️"
        testo: Cronologia.cerca.trim() ? "Nessun tavolo trovato per «" + Store.esc(Cronologia.cerca.trim()) + "»."
                                       : "Nessun tavolo chiuso in questo periodo."
    }

    Repeater {
        model: v.gruppi
        Column {
            width: v.width
            bottomPadding: 22
            spacing: 10
            Item {
                width: parent.width; height: tit.implicitHeight
                T { id: tit; text: Cronologia.etichettaSerata(modelData.k); font.pixelSize: 20; font.weight: Font.ExtraBold }
                T {
                    anchors { right: parent.right; baseline: tit.baseline }
                    text: modelData.tavoli.length + " " + Store.plurale(modelData.tavoli.length, "tavolo", "tavoli") + " · " + Store.euro(modelData.cent)
                    color: Theme.muted
                }
            }
            AutoGrid {
                width: parent.width
                minimo: 260; spazio: 12
                Repeater {
                    model: modelData.tavoli
                    Rectangle {
                        implicitHeight: colT.implicitHeight + 32
                        radius: Theme.radius
                        color: ma.containsMouse ? Theme.panel2 : Theme.panel
                        border.color: ma.containsMouse ? Theme.line2 : Theme.line
                        Column {
                            id: colT
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
                            spacing: 4
                            Item {
                                width: parent.width; height: n.implicitHeight
                                T { id: n; width: parent.width - tot.implicitWidth - 10; text: modelData.nome; font.pixelSize: 20; font.weight: Font.ExtraBold; elide: Text.ElideRight }
                                T { id: tot; anchors { right: parent.right; baseline: n.baseline } text: Store.euro(Cronologia.totaleTavolo(modelData)); font.pixelSize: 18; font.weight: Font.Bold; color: Theme.cream }
                            }
                            T {
                                text: Qt.formatTime(new Date(modelData.aperto), "HH:mm") + " – " + Qt.formatTime(new Date(modelData.chiuso), "HH:mm")
                                      + " · " + Cronologia.durata(modelData.chiuso - modelData.aperto)
                                color: Theme.muted; font.pixelSize: 13
                            }
                            T {
                                width: parent.width
                                text: { const n = Cronologia.pezziTavolo(modelData); return n + " " + Store.plurale(n, "articolo", "articoli") + (modelData.incassi.length > 1 ? " · pagato in " + modelData.incassi.length + " volte" : "") }
                                color: Theme.muted; font.pixelSize: 13
                            }
                        }
                        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Ui.apri("Storico", { voce: modelData }) }
                    }
                }
            }
        }
    }
}
