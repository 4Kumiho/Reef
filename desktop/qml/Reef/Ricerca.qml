import QtQuick
import QtQuick.Controls.Basic

// Campo di ricerca (.search)
TextField {
    id: f
    font.family: Theme.font
    font.pixelSize: 16
    color: Theme.white
    placeholderTextColor: Theme.placeholder
    selectionColor: Theme.cream
    selectedTextColor: Theme.night
    leftPadding: 16; rightPadding: 16; topPadding: 14; bottomPadding: 14
    background: Rectangle {
        radius: 10
        color: Theme.panel
        border.color: f.activeFocus ? Theme.cream : Theme.line
    }
}
