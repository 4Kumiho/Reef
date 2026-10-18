import QtQuick

// Griglia come CSS "repeat(auto-fill, minmax(minimo, 1fr))": tante colonne uguali quante ne entrano;
// ogni figlio prende la larghezza della colonna e l'altezza della riga (la più alta tra le sue implicitHeight).
Item {
    id: g
    property real minimo: 230
    property real spazio: 12
    readonly property int columns: Math.max(1, Math.floor((width + spazio) / (minimo + spazio)))
    readonly property real cella: Math.max(0, (width - spazio * (columns - 1)) / columns)
    implicitHeight: altezza

    property real altezza: 0
    property bool inAttesa: false
    property var collegati: []

    function richiedi() {
        // può arrivare da un figlio mentre la griglia viene distrutta (cambio pagina)
        if (!g || typeof g.disponi !== "function" || g.inAttesa) return;
        g.inAttesa = true;
        Qt.callLater(g.disponi);
    }
    function disponi() {
        if (!g || typeof g.richiedi !== "function") return;
        inAttesa = false;
        const figli = [];
        collegati = collegati.filter(function (c) { return Array.prototype.indexOf.call(children, c) >= 0 });
        for (let k = 0; k < children.length; k++) {
            const c = children[k];
            if (typeof c.itemAt === "function") continue; // il Repeater stesso
            if (collegati.indexOf(c) < 0) {
                collegati.push(c);
                c.implicitHeightChanged.connect(g.richiedi);
                c.visibleChanged.connect(g.richiedi);
            }
            if (c.visible) figli.push(c);
        }
        let y = 0;
        for (let i = 0; i < figli.length; i += columns) {
            const riga = figli.slice(i, i + columns);
            let h = 0;
            riga.forEach(function (c) { h = Math.max(h, c.implicitHeight) });
            riga.forEach(function (c, j) {
                c.x = j * (cella + spazio);
                c.y = y;
                c.width = cella;
                c.height = h;
            });
            y += h + spazio;
        }
        altezza = figli.length ? y - spazio : 0;
    }
    onWidthChanged: richiedi()
    onColumnsChanged: richiedi()
    onChildrenChanged: richiedi()
    Component.onCompleted: richiedi()
}
