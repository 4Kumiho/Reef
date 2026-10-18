import QtQuick

// Scelta della variante (formato del panino, gusto dello spritz…): anche con i tasti 1…9
Item {
    id: d
    property string formato: "normal"
    property var voce: null
    implicitHeight: testa.implicitHeight + griglia.implicitHeight + 26 + 6 + 14 + 24
    focus: true
    Component.onCompleted: Qt.callLater(function () { d.forceActiveFocus() })

    Keys.onPressed: function (e) {
        if (e.modifiers & (Qt.ControlModifier | Qt.AltModifier)) return;
        if (e.key >= Qt.Key_1 && e.key <= Qt.Key_9) {
            const i = e.key - Qt.Key_1;
            if (i < d.voce.varianti.length) { e.accepted = true; Store.aggiungiVariante(d.voce, i) }
        } else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
            e.accepted = true;
            Store.aggiungiVariante(d.voce, 0);
        }
    }

    Chiudi { anchors { right: parent.right; top: parent.top; margins: 12 } onClicked: Ui.chiudi(null) }

    Column {
        id: testa
        x: 24; y: 26
        width: d.width - 48
        T { width: parent.width - 48; text: d.voce.nome; font.pixelSize: 30; font.weight: Font.ExtraBold; font.letterSpacing: -0.3; wrapMode: Text.Wrap; lineHeight: 1.05 }
        T { width: parent.width; topPadding: 6; text: d.voce.descrizione || "Scegli:"; color: Theme.muted; wrapMode: Text.Wrap }
    }
    AutoGrid {
        id: griglia
        x: 24; y: testa.y + testa.height + 6 + 14
        width: d.width - 48
        minimo: 150; spazio: 8
        Repeater {
            model: d.voce.varianti
            Rectangle {
                implicitHeight: Math.max(62, testi.implicitHeight + 24)
                radius: 10
                color: ma.containsMouse ? Theme.panel2 : Theme.panel2
                border.color: ma.pressed ? Theme.cream : ma.containsMouse ? Theme.line2 : Theme.line
                scale: ma.pressed ? 0.97 : 1
                Column {
                    id: testi
                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 14; rightMargin: 14 }
                    spacing: 2
                    T { width: parent.width; text: Store.varNome(modelData); font.weight: Font.Bold; wrapMode: Text.Wrap }
                    T { width: parent.width; visible: text !== ""; text: Store.varInfo(modelData); color: Theme.muted; font.pixelSize: 12; wrapMode: Text.Wrap }
                    T { text: Store.euro(Store.cent(Store.varPrezzo(d.voce, modelData))); color: Theme.cream; font.pixelSize: 13; font.weight: Font.Bold }
                    T { visible: index < 9; text: "tasto " + (index + 1); color: Theme.muted; font.pixelSize: 11 }
                }
                MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Store.aggiungiVariante(d.voce, index) }
            }
        }
    }
}
