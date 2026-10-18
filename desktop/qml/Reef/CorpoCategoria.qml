import QtQuick

// Prodotti di una categoria nel menu del tavolo (vedi Store.corpoCategoria)
Column {
    id: c
    property string catId: ""
    readonly property var corpo: { Store.menu; return Store.corpoCategoria(catId) }
    readonly property var bottoni: corpo.bottoni || []
    spacing: 0

    Vuoto {
        width: c.width
        visible: c.corpo.tipo === "vuota"
        margine: 16
        testo: "Nessuna voce."
    }

    AutoGrid {
        width: c.width
        visible: c.bottoni.length > 0
        minimo: 210; spazio: 8
        Repeater { model: c.bottoni; ProdottoBtn { p: modelData } }
    }

    // categoria "a tendina": ogni voce si apre e mostra le sue varianti
    Column {
        width: c.width
        visible: c.corpo.tipo === "tendina"
        spacing: 8
        Repeater {
            model: c.corpo.tipo === "tendina" ? c.corpo.voci : []
            Acc {
                id: voce
                required property var modelData
                width: c.width
                livello: "ter"
                titolo: Store.titoloVoce(modelData)
                conteggio: Store.prodotti(modelData).length
                aperto: Store.apriVoce === modelData.id
                onToggle: Store.apriVoce = aperto ? "" : modelData.id
                corpo: Component {
                    AutoGrid {
                        minimo: 210; spazio: 8
                        Repeater { model: Store.bottoniVoceTendina(voce.modelData); ProdottoBtn { p: modelData } }
                    }
                }
            }
        }
    }

    // voci con tante varianti: un titoletto e sotto le varianti
    Repeater {
        model: c.corpo.gruppetti || []
        Column {
            width: c.width
            topPadding: index === 0 && c.bottoni.length === 0 ? 4 : 12
            Caps { leftPadding: 4; bottomPadding: 8; text: modelData.titolo; color: Theme.cream }
            AutoGrid {
                width: c.width
                minimo: 210; spazio: 8
                Repeater { model: modelData.bottoni; ProdottoBtn { p: modelData } }
            }
        }
    }
}
