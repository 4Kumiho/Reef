import QtQuick

// Cronologia → Prodotti più venduti (e meno venduti) nel periodo
Column {
    id: v
    spacing: 16
    readonly property var lista: { Cronologia.rev; Store.rev; Cronologia.tipo; Cronologia.rif; Cronologia.ordine; Cronologia.gruppo; return Cronologia.prodotti() }
    readonly property var mai: { v.lista; return Cronologia.maiVenduti(v.lista) }
    readonly property int pezzi: lista.reduce(function (n, p) { return n + p.qty }, 0)
    readonly property int cent: lista.reduce(function (n, p) { return n + p.cent }, 0)
    readonly property real massimo: lista.length ? (Cronologia.ordine === "incasso" ? lista[0].cent : lista[0].qty) : 1
    readonly property var meno: lista.length > 10 ? lista.slice(-10).reverse() : []

    AutoGrid {
        width: v.width
        minimo: 300; spazio: 12
        Riquadro { principale: true; etichetta: "Pezzi venduti"; valore: String(v.pezzi); nota: Store.euro(v.cent) + " incassati" }
        Riquadro { etichetta: "Prodotti diversi"; valore: String(v.lista.length) }
        Riquadro {
            etichetta: "Il più venduto"
            valore: v.lista.length ? v.lista[0].nome : "—"
            nota: v.lista.length ? v.lista[0].qty + " pezzi · " + Store.euro(v.lista[0].cent) : ""
        }
        Riquadro { etichetta: "Mai venduti"; valore: String(v.mai.length); nota: "voci del menu senza vendite" }
    }

    // filtri: gruppo del menu e ordinamento
    Flow {
        width: v.width
        spacing: 8
        Chip { text: "Tutto il menu"; on: Cronologia.gruppo === ""; onClicked: Cronologia.gruppo = "" }
        Repeater {
            model: { Store.menu; return Store.gruppi() }
            Chip { text: modelData.nome; on: Cronologia.gruppo === modelData.id; onClicked: Cronologia.gruppo = modelData.id }
        }
    }
    Row {
        spacing: 8
        T { anchors.verticalCenter: parent.verticalCenter; text: "Ordina per"; color: Theme.muted; font.pixelSize: 13; rightPadding: 4 }
        Chip { text: "Pezzi venduti"; on: Cronologia.ordine === "pezzi"; onClicked: Cronologia.ordine = "pezzi" }
        Chip { text: "Incasso"; on: Cronologia.ordine === "incasso"; onClicked: Cronologia.ordine = "incasso" }
    }

    // classifica
    Rectangle {
        width: v.width
        height: colL.implicitHeight + 40
        radius: Theme.radius
        color: Theme.panel
        border.color: Theme.line
        Column {
            id: colL
            x: 20; y: 20
            width: parent.width - 40
            spacing: 2
            Caps { text: "Classifica"; dimensione: 12; bottomPadding: 10 }
            Vuoto { width: parent.width; visible: v.lista.length === 0; margine: 16; testo: "Nessun prodotto venduto in questo periodo." }
            Repeater {
                model: v.lista
                RigaProdotto { width: colL.width; p: modelData; posizione: index + 1; massimo: v.massimo }
            }
        }
    }

    // i meno venduti (tra quelli venduti almeno una volta)
    Rectangle {
        visible: v.meno.length > 0
        width: v.width
        height: colM.implicitHeight + 40
        radius: Theme.radius
        color: Theme.panel
        border.color: Theme.line
        Column {
            id: colM
            x: 20; y: 20
            width: parent.width - 40
            spacing: 2
            Caps { text: "Meno venduti"; dimensione: 12; bottomPadding: 10 }
            Repeater {
                model: v.meno
                RigaProdotto { width: colM.width; p: modelData; posizione: v.lista.length - index; massimo: v.massimo }
            }
        }
    }

    // mai venduti
    Rectangle {
        visible: v.mai.length > 0
        width: v.width
        height: colN.implicitHeight + 40
        radius: Theme.radius
        color: Theme.panel
        border.color: Theme.line
        Column {
            id: colN
            x: 20; y: 20
            width: parent.width - 40
            spacing: 10
            Caps { text: "Mai venduti in questo periodo · " + v.mai.length; dimensione: 12 }
            Flow {
                width: parent.width
                spacing: 8
                Repeater {
                    model: v.mai
                    Rectangle {
                        width: tn.implicitWidth + 24; height: 34; radius: 17
                        color: "transparent"; border.color: Theme.line
                        T { id: tn; anchors.centerIn: parent; text: modelData.nome; font.pixelSize: 13; color: Theme.muted }
                    }
                }
            }
        }
    }
}
