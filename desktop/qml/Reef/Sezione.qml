import QtQuick

// Titoletto di sezione con la riga che prosegue (.editor h4)
Item {
    id: s
    property string text: ""
    implicitHeight: t.implicitHeight
    Caps { id: t; text: s.text; dimensione: 11; font.weight: Font.ExtraBold }
    Rectangle {
        anchors { left: t.right; leftMargin: 12; right: parent.right; verticalCenter: t.verticalCenter }
        height: 1; color: Theme.line
    }
}
