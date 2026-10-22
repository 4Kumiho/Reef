import QtQuick

// Cronologia → Serate: quanto si è incassato, con la serie nel tempo e la classifica delle serate
Column {
    id: v
    spacing: 16
    readonly property var dati: { Cronologia.rev; Store.rev; Cronologia.tipo; Cronologia.rif; return Cronologia.riepilogo() }
    readonly property var serie: { Cronologia.rev; Store.rev; Cronologia.tipo; Cronologia.rif; return Cronologia.serie() }
    readonly property var classifica: { Cronologia.rev; Store.rev; Cronologia.tipo; Cronologia.rif; return Cronologia.tipo === "serata" ? [] : Cronologia.classificaSerate() }

    AutoGrid {
        width: v.width
        minimo: 300; spazio: 12
        Riquadro { principale: true; etichetta: "Incasso"; valore: Store.euro(v.dati.cent); nota: v.dati.tavoli + " " + Store.plurale(v.dati.tavoli, "tavolo", "tavoli") }
        Riquadro { etichetta: "Media per tavolo"; valore: v.dati.tavoli ? Store.euro(v.dati.mediaTavolo) : "—" }
        Riquadro {
            visible: Cronologia.tipo !== "serata"
            etichetta: "Media per serata"
            valore: v.dati.serate ? Store.euro(v.dati.mediaSerata) : "—"
            nota: v.dati.serate + " " + Store.plurale(v.dati.serate, "serata", "serate") + " con incassi"
        }
        Riquadro {
            visible: Cronologia.tipo !== "serata"
            etichetta: "Serata migliore"
            valore: v.dati.migliore ? Store.euro(v.dati.migliore.cent) : "—"
            nota: v.dati.migliore ? Cronologia.etichettaSerata(v.dati.migliore.k) : ""
        }
        Riquadro {
            visible: Cronologia.tipo === "serata"
            etichetta: "Ora di punta"
            valore: v.dati.punta ? (v.dati.punta.h < 10 ? "0" : "") + v.dati.punta.h + ":00" : "—"
            nota: v.dati.punta ? Store.euro(v.dati.punta.cent) + " incassati" : ""
        }
    }

    // grafico
    Rectangle {
        width: v.width
        height: colG.implicitHeight + 40
        radius: Theme.radius
        color: Theme.panel
        border.color: Theme.line
        Column {
            id: colG
            x: 20; y: 20
            width: parent.width - 40
            spacing: 14
            Item {
                width: parent.width; height: tg.implicitHeight
                Caps { id: tg; text: v.serie.titolo; dimensione: 12 }
                T {
                    anchors { right: parent.right; verticalCenter: tg.verticalCenter }
                    visible: Cronologia.tipo === "settimana" || Cronologia.tipo === "mese"
                    text: "Clicca una colonna per vedere quella serata"
                    font.pixelSize: 12; color: Theme.muted
                }
            }
            GraficoBarre {
                width: parent.width
                height: 300
                barre: v.serie.barre
                cliccabile: Cronologia.tipo === "settimana" || Cronologia.tipo === "mese"
                onScelta: function (i) { Cronologia.apriSerata(v.serie.barre[i].serata) }
            }
            Vuoto { width: parent.width; visible: v.dati.cent === 0; margine: 4; testo: "Nessun incasso in questo periodo." }
        }
    }

    // classifica delle serate
    Rectangle {
        visible: v.classifica.length > 0
        width: v.width
        height: colC.implicitHeight + 40
        radius: Theme.radius
        color: Theme.panel
        border.color: Theme.line
        Column {
            id: colC
            x: 20; y: 20
            width: parent.width - 40
            spacing: 4
            Caps { text: "Serate migliori"; dimensione: 12; bottomPadding: 10 }
            Repeater {
                model: v.classifica.slice(0, 10)
                Rectangle {
                    width: colC.width; height: 52; radius: 8
                    color: ma.containsMouse ? Theme.panel2 : "transparent"
                    T { x: 12; anchors.verticalCenter: parent.verticalCenter; width: 28; text: index + 1; color: Theme.muted; font.weight: Font.Bold }
                    T {
                        x: 48; anchors.verticalCenter: parent.verticalCenter
                        width: parent.width * 0.38
                        text: Cronologia.etichettaSerata(modelData.k)
                        font.weight: Font.Bold; elide: Text.ElideRight
                    }
                    T {
                        x: 48 + parent.width * 0.38 + 12; anchors.verticalCenter: parent.verticalCenter
                        text: modelData.tavoli + " " + Store.plurale(modelData.tavoli, "tavolo", "tavoli")
                        color: Theme.muted; font.pixelSize: 13
                    }
                    Rectangle {
                        x: parent.width * 0.62; anchors.verticalCenter: parent.verticalCenter
                        width: (parent.width * 0.38 - 130) * modelData.cent / v.classifica[0].cent
                        height: 10; radius: 3
                        color: Theme.cream
                    }
                    T {
                        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                        text: Store.euro(modelData.cent)
                        font.weight: Font.Bold
                    }
                    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Cronologia.apriSerata(modelData.k) }
                }
            }
        }
    }

    // nella singola serata: scorciatoia ai tavoli
    Btn {
        visible: Cronologia.tipo === "serata" && v.dati.tavoli > 0
        text: "Vedi i tavoli di questa serata"
        onClicked: Cronologia.pagina = "tavoli"
    }
}
