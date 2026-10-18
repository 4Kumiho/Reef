import QtQuick

// Messaggio "niente da mostrare" (.empty)
Column {
    id: v
    property string icona: ""
    property string testo: ""
    property real margine: 56
    topPadding: margine; bottomPadding: margine
    spacing: 10
    Text {
        visible: v.icona !== ""
        anchors.horizontalCenter: parent.horizontalCenter
        text: v.icona
        font.family: Theme.emoji
        font.pixelSize: 40
    }
    T {
        width: v.width
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        textFormat: Text.StyledText
        lineHeight: 1.6
        color: Theme.muted
        text: v.testo
    }
}
