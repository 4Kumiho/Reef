import QtQuick

// Cronologia: tavoli chiusi, serate, prodotti più venduti — con lo stesso periodo per tutte e tre
Column {
    id: v
    spacing: 0
    Component.onCompleted: Cronologia.carica()

    function focusRicerca() { if (pagina.item && pagina.item.focusRicerca) pagina.item.focusRicerca() }

    TitoloPagina {
        width: v.width
        titolo: "Cronologia"
        sub: "le serate vanno dalle " + Cronologia.oraCambio + ":00 alle " + (Cronologia.oraCambio - 1) + ":59 del giorno dopo"
    }

    // le tre pagine
    Row {
        spacing: 8
        bottomPadding: 18
        Repeater {
            model: [{ id: "serate", t: "Serate" }, { id: "prodotti", t: "Prodotti più venduti" }, { id: "tavoli", t: "Tavoli chiusi" }]
            Rectangle {
                readonly property bool on: Cronologia.pagina === modelData.id
                width: et.implicitWidth + 44; height: 48; radius: 10
                color: on ? Theme.cream : ma.containsMouse ? Theme.panel2 : "transparent"
                border.color: on ? Theme.cream : Theme.line2
                Caps {
                    id: et
                    anchors.centerIn: parent
                    text: modelData.t
                    dimensione: 12; spaziatura: 0.12
                    color: parent.on ? Theme.night : Theme.white
                }
                MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Cronologia.pagina = modelData.id }
            }
        }
    }

    // periodo: tipo + frecce
    Item {
        width: v.width
        height: 48
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            Repeater {
                model: [{ id: "serata", t: "Serata" }, { id: "settimana", t: "Settimana" }, { id: "mese", t: "Mese" }, { id: "anno", t: "Anno" }, { id: "tutto", t: "Tutto" }]
                Chip { text: modelData.t; on: Cronologia.tipo === modelData.id; onClicked: Cronologia.imposta(modelData.id) }
            }
        }
        Row {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            spacing: 8
            Btn { text: "‹"; dimensione: 18; implicitWidth: 48; enabled: Cronologia.puoIndietro(); onClicked: Cronologia.sposta(-1) }
            Rectangle {
                width: Math.max(300, periodo.implicitWidth + 32); height: 48; radius: 10
                color: Theme.panel; border.color: Theme.line
                T {
                    id: periodo
                    anchors.centerIn: parent
                    text: { Cronologia.rev; return Cronologia.etichetta() }
                    font.pixelSize: 16; font.weight: Font.Bold
                }
            }
            Btn { text: "›"; dimensione: 18; implicitWidth: 48; enabled: { Cronologia.rif; Cronologia.tipo; return Cronologia.puoAvanti() } onClicked: Cronologia.sposta(1) }
            Btn {
                text: "Oggi"; small: true; implicitHeight: 48
                enabled: Cronologia.tipo !== "tutto"
                onClicked: Cronologia.rif = Date.now()
            }
        }
    }
    Item { width: 1; height: 20 }

    Loader {
        id: pagina
        width: v.width
        sourceComponent: Cronologia.pagina === "tavoli" ? cTavoli : Cronologia.pagina === "prodotti" ? cProdotti : cSerate
    }
    Component { id: cSerate; CronoSerate {} }
    Component { id: cProdotti; CronoProdotti {} }
    Component { id: cTavoli; CronoTavoli {} }
}
