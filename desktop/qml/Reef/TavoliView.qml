import QtQuick

// Tutti i tavoli aperti
Column {
    id: v
    spacing: 0

    TitoloPagina {
        width: v.width
        titolo: "Tavoli"
        sub: { Store.rev; const n = Store.tavoli.length; return n ? n + " " + Store.plurale(n, "aperto", "aperti") + " · " + Store.euro(Store.totaleAperti()) + " da incassare" : "" }
        pulsante: "+ Nuovo tavolo"
        kbd: "N"
        onClicked: Store.nuovoTavolo()
    }

    Vuoto {
        width: v.width
        visible: Store.rev >= 0 && Store.tavoli.length === 0
        icona: "🎸"
        testo: "Nessun tavolo aperto.<br>Premi <b>+ Nuovo tavolo</b> quando arriva qualcuno."
    }

    AutoGrid {
        id: griglia
        width: v.width
        visible: Store.tavoli.length > 0
        minimo: 230; spazio: 12
        Repeater {
            model: { Store.rev; return Store.tavoli.slice() }
            Rectangle {
                id: card
                implicitHeight: Math.max(140, col.implicitHeight + 34)
                radius: Theme.radius
                color: ma.containsMouse ? Theme.panel2 : Theme.panel
                border.color: ma.containsMouse || ma.pressed ? Theme.line2 : Theme.line
                scale: ma.pressed ? 0.98 : 1
                Column {
                    id: col
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 18 }
                    spacing: 4
                    T { width: parent.width; text: modelData.nome; font.pixelSize: 26; font.weight: Font.ExtraBold; wrapMode: Text.Wrap; lineHeight: 1.05 }
                    T { text: { Store.rev; const n = Store.pezzi(modelData); return n + " " + Store.plurale(n, "articolo", "articoli") } color: Theme.muted; font.pixelSize: 13 }
                    T { text: Store.tempo(modelData.creato); color: Theme.muted; font.pixelSize: 13 }
                    Item { width: 1; height: 40 }
                }
                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: 18; rightMargin: 18; bottomMargin: 16 + 10 + tot.implicitHeight }
                    height: 1; color: Theme.line
                }
                T {
                    id: tot
                    anchors { left: parent.left; bottom: parent.bottom; leftMargin: 18; bottomMargin: 16 }
                    text: { Store.rev; return Store.euro(Store.totale(modelData)) }
                    font.pixelSize: 22; font.weight: Font.Bold
                    color: Theme.cream
                }
                MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Store.vai("tavolo", modelData.id) }
            }
        }
        // + Nuovo tavolo
        Item {
            implicitHeight: 140
            scale: nm.pressed ? 0.98 : 1
            Rectangle { anchors.fill: parent; radius: Theme.radius; color: nm.containsMouse ? Theme.panel2 : Theme.panel }
            Tratteggio { anchors.fill: parent; raggio: Theme.radius }
            Column {
                anchors.centerIn: parent
                spacing: 4
                T { anchors.horizontalCenter: parent.horizontalCenter; text: "+"; font.pixelSize: 40; font.weight: Font.Light; color: Theme.cream }
                T { anchors.horizontalCenter: parent.horizontalCenter; text: "Nuovo tavolo"; font.pixelSize: 13; color: Theme.muted }
            }
            MouseArea { id: nm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Store.nuovoTavolo() }
        }
    }
}
