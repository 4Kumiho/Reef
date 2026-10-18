import QtQuick
import QtQuick.Controls.Basic

// Menu a discesa delle finestre (.dlg select)
ComboBox {
    id: c
    font.family: Theme.font
    font.pixelSize: 18
    font.weight: Font.Medium
    implicitHeight: 52
    leftPadding: 14; rightPadding: 14

    contentItem: T {
        leftPadding: 0
        text: c.displayText
        font: c.font
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    indicator: Item {}
    background: Rectangle {
        radius: 10
        color: Theme.night
        border.color: c.activeFocus || c.popup.visible ? Theme.cream : Theme.line2
    }
    delegate: ItemDelegate {
        id: voce
        required property var modelData
        required property int index
        width: c.popup.width
        height: 40
        highlighted: c.highlightedIndex === index
        contentItem: T {
            text: voce.modelData[c.textRole]
            font.pixelSize: 15
            font.weight: c.currentIndex === voce.index ? Font.Bold : Font.Medium
            color: c.currentIndex === voce.index ? Theme.cream : Theme.white
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle { color: voce.highlighted ? Theme.panel2 : "transparent"; radius: 6 }
    }
    popup: Popup {
        y: c.height + 4
        width: c.width
        implicitHeight: Math.min(contentItem.implicitHeight + 12, 360)
        padding: 6
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: c.popup.visible ? c.delegateModel : null
            currentIndex: c.highlightedIndex
        }
        background: Rectangle { color: Theme.coal; border.color: Theme.line2; radius: 10 }
    }
}
