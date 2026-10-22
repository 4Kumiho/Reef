import QtQuick

// Una riga della classifica dei prodotti: posizione, nome, barra, pezzi e incasso
Item {
    id: r
    property var p
    property int posizione: 0
    property real massimo: 1
    readonly property real valore: Cronologia.ordine === "incasso" ? p.cent : p.qty
    height: 50

    T { x: 4; width: 34; anchors.verticalCenter: parent.verticalCenter; text: r.posizione; color: Theme.muted; font.weight: Font.Bold; horizontalAlignment: Text.AlignRight }
    Tile { id: tile; x: 44; anchors.verticalCenter: parent.verticalCenter; emoji: r.p.emoji; size: 30; fontSize: 15; margine: 2 }
    T {
        id: nome
        x: tile.x + tile.width + 8
        width: r.width * 0.36 - x
        anchors.verticalCenter: parent.verticalCenter
        text: r.p.nome
        font.weight: Font.Bold
        elide: Text.ElideRight
    }
    Rectangle {
        x: r.width * 0.36 + 8
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(3, (r.width * 0.64 - 8 - 230) * r.valore / Math.max(1, r.massimo))
        height: 10; radius: 3
        color: Theme.cream
    }
    T {
        anchors { right: parent.right; rightMargin: 120; verticalCenter: parent.verticalCenter }
        text: r.p.qty + " pz"
        font.weight: Cronologia.ordine === "pezzi" ? Font.Bold : Font.Normal
        color: Cronologia.ordine === "pezzi" ? Theme.white : Theme.muted
    }
    T {
        anchors { right: parent.right; rightMargin: 4; verticalCenter: parent.verticalCenter }
        width: 108
        horizontalAlignment: Text.AlignRight
        text: Store.euro(r.p.cent)
        font.weight: Cronologia.ordine === "incasso" ? Font.Bold : Font.Normal
        color: Cronologia.ordine === "incasso" ? Theme.white : Theme.muted
    }
    Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.line }
}
