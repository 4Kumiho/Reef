import QtQuick
import QtQuick.Shapes

// Badge rotondo con doppio anello (rosso fuori, blu dentro), come il logo (.rf-ring)
Item {
    id: tile
    property string emoji: "🧾"
    property real size: 46
    property real fontSize: 22
    property real margine: 4
    implicitWidth: size + margine * 2
    implicitHeight: size + margine * 2

    Rectangle {
        anchors.centerIn: parent
        width: tile.size + 4; height: width; radius: width / 2
        color: Theme.red
    }
    Rectangle {
        anchors.centerIn: parent
        width: tile.size; height: width; radius: width / 2
        color: Theme.navy
    }
    Shape {
        id: fondo
        anchors.centerIn: parent
        width: tile.size - 4; height: width
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeWidth: -1
            fillGradient: RadialGradient {
                centerX: fondo.width * 0.35; centerY: fondo.width * 0.3
                focalX: centerX; focalY: centerY
                centerRadius: fondo.width * 0.67; focalRadius: 0
                GradientStop { position: 0; color: "#34324a" }
                GradientStop { position: 1; color: Theme.coal }
            }
            PathRectangle { x: 0; y: 0; width: fondo.width; height: fondo.width; radius: fondo.width / 2 }
        }
    }
    Text {
        anchors.centerIn: parent
        text: tile.emoji || "🧾"
        font.family: Theme.emoji
        font.pixelSize: tile.fontSize
    }
}
