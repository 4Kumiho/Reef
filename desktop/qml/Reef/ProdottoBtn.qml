import QtQuick

// Bottone di un prodotto nel menu del tavolo (.pbtn).
// p = { d: voce, i: indice variante oppure null, titolo, voce: true se il bottone apre la scelta delle varianti }
Rectangle {
    id: b
    property var p
    readonly property var d: p.d
    readonly property var i: p.i === undefined ? null : p.i
    readonly property bool voce: !!p.voce
    property bool flash: false

    implicitHeight: Math.max(64, testi.implicitHeight + 16)
    radius: 10
    color: flash ? Theme.creamSoft : Theme.panel2
    border.color: flash ? Theme.cream : ma.containsMouse ? Theme.line2 : Theme.line
    scale: ma.pressed ? 0.97 : 1

    readonly property string prezzo: {
        if (voce) return Store.prezzoLabel(d);
        const v = i === null ? d.prezzo : Store.varPrezzo(d, d.varianti[i]);
        const info = i === null ? "" : Store.varInfo(d.varianti[i]);
        return (v ? Store.euro(Store.cent(v)) : "Omaggio") + (info ? " · " + info : "");
    }
    readonly property int quanti: {
        Store.rev;
        return Store.quanti(Store.tavolo(), d.id, voce ? null : Store.nomeRiga(d, i));
    }

    Tile {
        id: tile
        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
        emoji: b.d.emoji || "🧾"
        size: 38; fontSize: 18
    }
    Column {
        id: testi
        anchors { left: tile.right; leftMargin: 10; right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
        T { width: parent.width; text: b.p.titolo; font.pixelSize: 14; font.weight: Font.Bold; wrapMode: Text.Wrap; lineHeight: 1.2 }
        T { width: parent.width; topPadding: 2; text: b.prezzo; font.pixelSize: 12; color: Theme.muted; wrapMode: Text.Wrap }
        T {
            visible: b.voce && !!b.d.descrizione
            width: parent.width; topPadding: 3
            text: b.d.descrizione || ""
            font.pixelSize: 11; color: Theme.muted; lineHeight: 1.3
            wrapMode: Text.Wrap; maximumLineCount: 2; elide: Text.ElideRight
        }
    }
    Rectangle {
        visible: b.quanti > 0
        anchors { right: parent.right; top: parent.top; rightMargin: -7; topMargin: -7 }
        width: Math.max(24, n.implicitWidth + 12); height: 24; radius: 12
        color: Theme.cream
        T { id: n; anchors.centerIn: parent; text: b.quanti; font.pixelSize: 12; font.weight: Font.ExtraBold; color: Theme.night }
    }
    Timer { id: spegni; interval: 250; onTriggered: b.flash = false }
    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: if (Store.aggiungi(b.d, b.i)) { b.flash = true; spegni.restart() }
    }
}
