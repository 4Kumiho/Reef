import QtQuick

// Etichette maiuscole spaziate, come "ROCK 'N' ROLL · DRINK 'N' DINE" (.rf-caps)
T {
    property real spaziatura: 0.2 // in em
    property real dimensione: 11
    font.pixelSize: dimensione
    font.weight: Font.Bold
    font.capitalization: Font.AllUppercase
    font.letterSpacing: dimensione * spaziatura
}
