import QtQuick

// Testata: logo + STAFF a sinistra, schede Tavoli / Menu a destra
Rectangle {
    id: top
    height: Theme.topH
    color: Qt.rgba(21 / 255, 20 / 255, 31 / 255, 0.9)
    Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.line }
    MouseArea { anchors.fill: parent } // non far passare i clic alla pagina sotto

    Row {
        anchors { left: parent.left; leftMargin: 24; verticalCenter: parent.verticalCenter }
        spacing: 12
        Image {
            width: 50; height: 50
            source: backend.asset(Store.bar.logo)
            sourceSize: Qt.size(100, 100)
            smooth: true; mipmap: true
        }
        Caps { anchors.verticalCenter: parent.verticalCenter; text: "Staff"; color: Theme.muted }
    }
    MouseArea {
        x: 24; width: 130; height: parent.height
        cursorShape: Qt.PointingHandCursor
        onClicked: Store.vai("home")
    }

    Row {
        anchors { right: parent.right; rightMargin: 24; verticalCenter: parent.verticalCenter }
        spacing: 4
        Repeater {
            model: [{ t: "Tavoli", v: "tavoli" }, { t: "Menu", v: "menu" }]
            Rectangle {
                id: tab
                readonly property bool on: modelData.v === "menu" ? Store.view === "menu" : (Store.view === "tavoli" || Store.view === "tavolo")
                width: lbl.implicitWidth + 36; height: 42
                radius: 8
                color: ma.containsMouse ? Qt.rgba(1, 1, 1, 0.04) : "transparent"
                Caps {
                    id: lbl
                    anchors.centerIn: parent
                    text: modelData.t
                    dimensione: 12
                    spaziatura: 0.16
                    color: tab.on || ma.containsMouse ? Theme.white : Theme.muted
                }
                Rectangle {
                    visible: tab.on
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: 18; rightMargin: 18; bottomMargin: 4 }
                    height: 2; color: Theme.cream
                }
                MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Store.vai(modelData.v) }
            }
        }
    }
}
