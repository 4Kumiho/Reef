import QtQuick
import QtQuick.Controls.Basic

// Campo di testo delle finestre (.dlg input)
TextField {
    id: f
    property bool decimale: false
    font.family: Theme.font
    font.pixelSize: 18
    font.weight: Font.Medium
    color: Theme.white
    placeholderTextColor: Theme.placeholder
    selectionColor: Theme.cream
    selectedTextColor: Theme.night
    padding: 14
    inputMethodHints: decimale ? Qt.ImhFormattedNumbersOnly : Qt.ImhNone
    background: Rectangle {
        radius: 10
        color: Theme.night
        border.color: f.activeFocus ? Theme.cream : Theme.line2
    }
}
