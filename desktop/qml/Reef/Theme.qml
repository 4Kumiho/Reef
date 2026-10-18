pragma Singleton
import QtQuick

// Identità Reef Café: blu notte e rosso mattone del badge del logo,
// crema dorata della scritta "Reef Café" come accento.
QtObject {
    readonly property color night: "#15141f"
    readonly property color coal: "#1b1a28"
    readonly property color panel: "#222134"
    readonly property color panel2: "#2b2a40"
    readonly property color navy: "#353349"
    readonly property color line: Qt.rgba(235 / 255, 196 / 255, 133 / 255, 0.12)
    readonly property color line2: Qt.rgba(235 / 255, 196 / 255, 133 / 255, 0.28)
    readonly property color white: "#f7efe2"
    readonly property color muted: "#a9a3b4"
    readonly property color placeholder: Qt.rgba(169 / 255, 163 / 255, 180 / 255, 0.8)
    readonly property color cream: "#ebc485"
    readonly property color creamHover: "#f3d39f"
    readonly property color creamSoft: Qt.rgba(235 / 255, 196 / 255, 133 / 255, 0.13)
    readonly property color creamLine: Qt.rgba(235 / 255, 196 / 255, 133 / 255, 0.5)
    readonly property color red: "#a34849"
    readonly property color redHi: "#e0605c"
    readonly property color redSoft: Qt.rgba(224 / 255, 96 / 255, 92 / 255, 0.12)
    readonly property color redLine: Qt.rgba(224 / 255, 96 / 255, 92 / 255, 0.6)

    readonly property string font: "Montserrat"
    readonly property string emoji: "Segoe UI Emoji"
    readonly property int radius: 12
    readonly property int topH: 68
}
