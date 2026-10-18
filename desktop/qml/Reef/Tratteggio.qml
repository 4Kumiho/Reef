import QtQuick
import QtQuick.Shapes

// Bordo tratteggiato arrotondato (border-style: dashed)
Shape {
    id: s
    property color colore: Theme.line2
    property real raggio: 12
    preferredRendererType: Shape.CurveRenderer
    ShapePath {
        strokeColor: s.colore
        strokeWidth: 1
        strokeStyle: ShapePath.DashLine
        dashPattern: [4, 3]
        fillColor: "transparent"
        PathRectangle { x: 0.5; y: 0.5; width: s.width - 1; height: s.height - 1; radius: s.raggio }
    }
}
