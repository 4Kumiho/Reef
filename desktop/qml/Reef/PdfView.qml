import QtQuick

// «Visualizza menu»: le pagine del menu cartaceo, una sotto l'altra, con lo zoom
Column {
    id: v
    spacing: 0

    readonly property var pagine: backend.pagineMenu()
    readonly property var livelli: [0.5, 0.65, 0.8, 1, 1.25, 1.5]
    // larghezza di una pagina: 820 px al 100%, mai più larga dello spazio disponibile
    readonly property real larghezzaPagina: Math.min(v.width, 820 * livelli[Store.zoomMenu])

    function zoom(passo) { Store.zoomMenu = Math.max(0, Math.min(livelli.length - 1, Store.zoomMenu + passo)) }
    function focusRicerca() {}

    Item {
        width: v.width
        height: titolo.implicitHeight
        TitoloPagina {
            id: titolo
            width: parent.width
            titolo: "Menu del locale"
            sub: v.pagine.length + " pagine"
        }
        Row {
            anchors { right: parent.right; top: parent.top; topMargin: 4 }
            spacing: 8
            Btn { text: "−"; dimensione: 16; implicitWidth: 48; enabled: Store.zoomMenu > 0; onClicked: v.zoom(-1) }
            Rectangle {
                width: 84; height: 48; radius: 10
                color: "transparent"; border.color: Theme.line
                T { anchors.centerIn: parent; text: Math.round(v.livelli[Store.zoomMenu] * 100) + "%"; font.weight: Font.Bold }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Store.zoomMenu = 3 }
            }
            Btn { text: "+"; dimensione: 16; implicitWidth: 48; enabled: Store.zoomMenu < v.livelli.length - 1; onClicked: v.zoom(1) }
        }
    }

    Vuoto {
        width: v.width
        visible: v.pagine.length === 0
        icona: "📄"
        testo: "Il menu in PDF non è incluso in questa versione dell'app."
    }

    Column {
        width: v.width
        spacing: 24
        Repeater {
            model: v.pagine
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: v.larghezzaPagina + 2
                height: Math.round(v.larghezzaPagina * 842.25 / 595.5) + 2
                radius: 6
                color: Theme.panel
                border.color: Theme.line2
                Image {
                    anchors { fill: parent; margins: 1 }
                    source: modelData
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                    mipmap: true
                }
            }
        }
    }
    Item { width: 1; height: 24 }
}
