import QtQuick

// Grafico a colonne con una sola serie (incasso). barre: [{ etichetta, titolo, cent }]
// Colonne sottili con l'estremità arrotondata, griglia leggera, valore nel riquadro al passaggio del mouse.
Item {
    id: g
    property var barre: []
    property int sopra: -1
    signal scelta(int indice)
    property bool cliccabile: false

    implicitHeight: 300
    readonly property real sinistra: 72
    readonly property real basso: 30
    readonly property real alto: 12
    readonly property real areaW: width - sinistra
    readonly property real areaH: height - basso - alto
    readonly property real massimo: {
        let m = 0;
        barre.forEach(function (b) { m = Math.max(m, b.cent) });
        return m;
    }
    // fondo scala «tondo» (1, 2, 2.5, 5 × 10^n euro) diviso in 4 righe
    readonly property real scala: {
        const euro = massimo / 100 / 4;
        if (euro <= 0) return 100 * 4;
        const p = Math.pow(10, Math.floor(Math.log(euro) / Math.LN10));
        const passi = [1, 2, 2.5, 5, 10];
        let passo = p * 10;
        for (let k = 0; k < passi.length; k++) if (passi[k] * p >= euro) { passo = passi[k] * p; break }
        return passo * 100 * 4;
    }
    readonly property real slot: barre.length ? areaW / barre.length : 0
    readonly property real spessore: Math.max(3, Math.min(24, slot * 0.62))
    // un'etichetta dell'asse ogni «ogni» colonne, così non si sovrappongono
    readonly property int ogni: Math.max(1, Math.ceil(52 / Math.max(1, slot)))

    function euroAsse(cent) {
        const e = Math.round(cent / 100);
        return (e >= 10000 ? String(e).replace(/\B(?=(\d{3})+(?!\d))/g, ".") : String(e)) + " €";
    }

    // righe orizzontali e valori dell'asse
    Repeater {
        model: 5
        Item {
            readonly property real y0: g.alto + g.areaH - index / 4 * g.areaH
            Rectangle { x: g.sinistra; y: parent.y0; width: g.areaW; height: 1; color: index === 0 ? Theme.line2 : Theme.line }
            T {
                x: 0; width: g.sinistra - 12
                y: parent.y0 - implicitHeight / 2
                horizontalAlignment: Text.AlignRight
                text: g.euroAsse(g.scala * index / 4)
                font.pixelSize: 11
                color: Theme.muted
            }
        }
    }

    // colonne
    Repeater {
        model: g.barre
        Item {
            x: g.sinistra + index * g.slot
            y: g.alto
            width: g.slot
            height: g.areaH + g.basso
            readonly property real h: g.scala > 0 ? modelData.cent / g.scala * g.areaH : 0
            Rectangle {
                visible: parent.h > 0
                anchors.horizontalCenter: parent.horizontalCenter
                y: g.areaH - height
                width: g.spessore
                height: Math.max(2, parent.h)
                color: g.sopra === index ? Theme.creamHover : Theme.cream
                topLeftRadius: Math.min(4, height / 2); topRightRadius: Math.min(4, height / 2)
            }
            T {
                visible: index % g.ogni === 0
                anchors.horizontalCenter: parent.horizontalCenter
                y: g.areaH + 8
                text: modelData.etichetta
                font.pixelSize: 11
                color: g.sopra === index ? Theme.white : Theme.muted
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: g.cliccabile && modelData.cent > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                onEntered: g.sopra = index
                onExited: if (g.sopra === index) g.sopra = -1
                onClicked: if (g.cliccabile && modelData.cent > 0) g.scelta(index)
            }
        }
    }

    // riquadro col valore della colonna sotto il mouse
    Rectangle {
        id: suggerimento
        visible: g.sopra >= 0 && g.sopra < g.barre.length
        readonly property var b: visible ? g.barre[g.sopra] : null
        readonly property real centro: g.sinistra + (g.sopra + 0.5) * g.slot
        width: Math.max(tt.implicitWidth, tv.implicitWidth) + 28
        height: colTip.implicitHeight + 20
        x: Math.max(0, Math.min(g.width - width, centro - width / 2))
        y: 0
        z: 5
        radius: 10
        color: Theme.coal
        border.color: Theme.line2
        Column {
            id: colTip
            x: 14; y: 10
            spacing: 2
            T { id: tt; text: suggerimento.b ? suggerimento.b.titolo : ""; font.pixelSize: 12; color: Theme.muted }
            T { id: tv; text: suggerimento.b ? Store.euro(suggerimento.b.cent) : ""; font.pixelSize: 18; font.weight: Font.Bold }
            T { visible: g.cliccabile && !!suggerimento.b && suggerimento.b.cent > 0; text: "Clic per aprire"; font.pixelSize: 11; color: Theme.muted }
        }
    }
}
