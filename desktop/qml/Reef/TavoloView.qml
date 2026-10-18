import QtQuick
import QtQuick.Layouts

// Dettaglio di un tavolo: a sinistra l'ordine col totale, a destra il menu per aggiungere
Item {
    id: v
    property var t: { Store.rev; return Store.tavolo() }
    property real scrollY: 0        // scorrimento della pagina (per tenere fermo l'ordine)
    property real viewTop: 0        // posizione di questa vista nella pagina
    property real altezzaFinestra: 900
    // copia nuova a ogni modifica, così le righe si aggiornano anche quando cambia solo una quantità
    readonly property var pay: { Store.payRev; const sel = Store.paySel(t); return sel ? Object.assign({}, sel) : null }

    implicitHeight: testata.height + 16 + Math.max(ordine.height, picker.height)

    function focusRicerca() { ricerca.forceActiveFocus() }
    Component.onCompleted: Qt.callLater(focusRicerca)

    /* ---------- Testata ---------- */
    Item {
        id: testata
        width: v.width
        height: 48 + 12 + since.implicitHeight
        Row {
            spacing: 12
            Btn { text: "‹ Tavoli"; onClicked: Store.vai("tavoli") }
            T {
                anchors.verticalCenter: parent.verticalCenter
                text: { Store.rev; return v.t ? v.t.nome : "" }
                font.pixelSize: 34; font.weight: Font.ExtraBold; font.letterSpacing: -0.34
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 44; height: 44; radius: 10
                color: "transparent"; border.color: Theme.line
                T { anchors.centerIn: parent; text: "✎"; color: rm.containsMouse ? Theme.cream : Theme.muted; font.pixelSize: 15 }
                MouseArea { id: rm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Store.rinomina(v.t) }
            }
        }
        T {
            id: since
            y: 60
            text: v.t ? Store.tempo(v.t.creato) : ""
            color: Theme.muted; font.pixelSize: 13
        }
    }

    readonly property real larghezzaOrdine: Math.max(380, (v.width - 16) * 0.9 / 2.1)

    /* ---------- Ordine ---------- */
    Rectangle {
        id: ordine
        width: v.larghezzaOrdine
        height: colOrdine.implicitHeight
        y: testata.height + 16 + Math.max(0, Math.min(v.scrollY + Theme.topH + 16 - v.viewTop - testata.height - 16,
                                                     picker.height - height))
        z: 2
        radius: Theme.radius
        color: Theme.panel
        border.color: Theme.line

        Column {
            id: colOrdine
            width: parent.width

            Flickable {
                id: righe
                width: parent.width
                height: Math.min(contentHeight, Math.max(120, v.altezzaFinestra - 360))
                contentHeight: colRighe.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                interactive: contentHeight > height
                Column {
                    id: colRighe
                    width: righe.width
                    Vuoto {
                        width: parent.width
                        visible: v.t && v.t.righe.length === 0
                        icona: "🍺"
                        testo: "Nessun ordine.<br>Aggiungi i prodotti dall'elenco."
                    }
                    Repeater {
                        model: { Store.rev; return v.t ? v.t.righe.slice() : [] }
                        Item {
                            id: riga
                            readonly property var r: modelData
                            width: colRighe.width
                            height: Math.max(44, info.implicitHeight) + 24
                            Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: Theme.line }
                            RowLayout {
                                anchors { fill: parent; leftMargin: 18; rightMargin: 18 }
                                spacing: 12
                                Column {
                                    id: info
                                    Layout.fillWidth: true
                                    T { width: parent.width; text: riga.r.nome; font.weight: Font.Bold; wrapMode: Text.Wrap }
                                    T { topPadding: 3; text: Store.euro(riga.r.prezzoCent) + " cad."; color: Theme.muted; font.pixelSize: 12 }
                                }
                                Rectangle {
                                    readonly property bool inPay: !!v.pay
                                    Layout.preferredWidth: 42 + passi.width + 42 + 2
                                    Layout.preferredHeight: 44
                                    radius: 10
                                    color: inPay ? Theme.creamSoft : "transparent"
                                    border.color: inPay ? Theme.cream : Theme.line2
                                    Row {
                                        anchors.centerIn: parent
                                        Passo { text: "−"; onClicked: v.pay ? Store.payImposta(riga.r, (v.pay[riga.r.id] || 0) - 1) : Store.dec(v.t, riga.r) }
                                        T {
                                            id: passi
                                            width: Math.max(40, implicitWidth + 8)
                                            anchors.verticalCenter: parent.verticalCenter
                                            horizontalAlignment: Text.AlignHCenter
                                            font.weight: Font.Bold
                                            color: v.pay ? Theme.cream : Theme.white
                                            text: v.pay ? (v.pay[riga.r.id] || 0) + "/" + riga.r.qty : riga.r.qty
                                        }
                                        Passo { text: "+"; onClicked: v.pay ? Store.payImposta(riga.r, (v.pay[riga.r.id] || 0) + 1) : Store.inc(v.t, riga.r) }
                                    }
                                }
                                Rectangle {
                                    visible: !!v.pay
                                    Layout.preferredWidth: tutti.implicitWidth + 20
                                    Layout.preferredHeight: tutti.implicitHeight + 16
                                    radius: 8; color: "transparent"; border.color: Theme.line
                                    T { id: tutti; anchors.centerIn: parent; text: "tutti"; font.pixelSize: 12; color: Theme.muted }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: Store.payImposta(riga.r, v.pay[riga.r.id] === riga.r.qty ? 0 : riga.r.qty)
                                    }
                                }
                                T {
                                    Layout.preferredWidth: 84
                                    horizontalAlignment: Text.AlignRight
                                    font.weight: Font.Bold
                                    text: Store.euro(v.pay ? (v.pay[riga.r.id] || 0) * riga.r.prezzoCent : riga.r.qty * riga.r.prezzoCent)
                                }
                            }
                        }
                    }
                }
            }

            // Totale
            Item {
                width: parent.width
                height: totV.implicitHeight + 36
                Caps {
                    anchors { left: parent.left; leftMargin: 18; baseline: totV.baseline }
                    text: v.pay ? "Da incassare ora" : "Totale"
                    dimensione: 12; color: Theme.muted
                }
                T {
                    id: totV
                    anchors { right: parent.right; rightMargin: 18; verticalCenter: parent.verticalCenter }
                    text: { Store.rev; Store.payRev; return v.t ? Store.euro(v.pay ? Store.payTotale(v.t) : Store.totale(v.t)) : "" }
                    font.pixelSize: 42; font.weight: Font.ExtraBold
                    color: v.pay ? Theme.cream : Theme.white
                }
            }
            T {
                visible: !!v.pay
                x: 18; width: parent.width - 36
                bottomPadding: 14
                wrapMode: Text.WordWrap
                textFormat: Text.StyledText
                color: Theme.muted; font.pixelSize: 13; lineHeight: 1.5
                text: { Store.rev; Store.payRev; return v.t ? "Seleziona cosa paga questa persona. Resteranno da pagare <b><font color=\"" + Theme.white + "\">" + Store.euro(Store.totale(v.t) - Store.payTotale(v.t)) + "</font></b>." : "" }
            }
            RowLayout {
                x: 18; width: parent.width - 36
                spacing: 10
                Btn { visible: !!v.pay; Layout.fillWidth: true; Layout.preferredWidth: 1; text: "Annulla"; onClicked: Store.payAnnulla() }
                Btn { visible: !!v.pay; Layout.fillWidth: true; Layout.preferredWidth: 1; text: "Tutto"; onClicked: Store.payTutto(v.t) }
                Btn {
                    visible: !!v.pay; Layout.fillWidth: true; Layout.preferredWidth: 1
                    tipo: "primary"
                    enabled: { Store.payRev; return v.t ? Store.payTotale(v.t) > 0 : false }
                    text: { Store.payRev; return "Incassa " + (v.t ? Store.euro(Store.payTotale(v.t)) : "") }
                    onClicked: Store.payConferma(v.t)
                }
                Btn {
                    visible: !v.pay; Layout.fillWidth: true; Layout.preferredWidth: 1
                    tipo: "primary"; text: "Paga separato"
                    enabled: { Store.rev; return !!v.t && v.t.righe.length > 0 }
                    onClicked: Store.pagaSeparato(v.t)
                }
                Btn { visible: !v.pay; Layout.fillWidth: true; Layout.preferredWidth: 1; tipo: "danger"; text: "Chiudi tavolo"; onClicked: Store.chiudiTavolo(v.t) }
            }
            Item { width: 1; height: 18 }
        }
    }

    /* ---------- Menu per aggiungere ---------- */
    Rectangle {
        id: picker
        x: v.larghezzaOrdine + 16
        y: testata.height + 16
        width: v.width - x
        height: colPicker.implicitHeight + 32
        radius: Theme.radius
        color: Theme.panel
        border.color: Theme.line
        opacity: v.pay ? 0.3 : 1
        enabled: !v.pay

        Column {
            id: colPicker
            x: 16; y: 16
            width: parent.width - 32

            Ricerca {
                id: ricerca
                width: parent.width
                placeholderText: "Cerca: spritz, birra, Nirvana, patatine…  (tasto /)"
                text: Store.pickQ
                onTextEdited: Store.pickQ = text
                Keys.onReturnPressed: aggiungiPrimo()
                Keys.onEnterPressed: aggiungiPrimo()
                Keys.onEscapePressed: function (e) { if (text) { Store.pickQ = ""; text = "" } else e.accepted = false }
                function aggiungiPrimo() {
                    const p = Store.primoProdotto();
                    if (p) Store.aggiungi(p.d, p.voce ? null : p.i);
                }
            }

            // Risultati della ricerca
            Item { width: 1; height: 12; visible: Store.pickQ.trim() !== "" }
            AutoGrid {
                width: parent.width
                visible: risultati.count > 0
                minimo: 210; spazio: 8
                Repeater {
                    id: risultati
                    model: Store.pickQ.trim() ? Store.cerca(Store.pickQ) : []
                    ProdottoBtn { p: modelData }
                }
            }
            Vuoto {
                width: parent.width
                visible: Store.pickQ.trim() !== "" && risultati.count === 0
                margine: 24
                testo: "Nessun risultato per «" + Store.esc(Store.pickQ.trim()) + "»."
            }

            // Menu a tendina
            Column {
                width: parent.width
                visible: Store.pickQ.trim() === ""
                topPadding: 12
                spacing: 8
                Repeater {
                    model: { Store.menu; return Store.gruppi() }
                    Acc {
                        id: gruppo
                        required property var modelData
                        width: parent.width
                        titolo: modelData.nome
                        conteggio: Store.quantiVoci(modelData.categorie)
                        aperto: Store.apriGruppo === modelData.id
                        onToggle: {
                            Store.apriGruppo = aperto ? "" : modelData.id;
                            if (Store.apriGruppo && modelData.categorie.length > 1) Store.apriCat = "";
                            if (Store.apriGruppo) Qt.callLater(function () { Ui.mostra(gruppo) });
                        }
                        corpo: Component {
                            Column {
                                spacing: 8
                                topPadding: gruppo.modelData.categorie.length > 1 ? 0 : 2
                                CorpoCategoria {
                                    width: parent.width
                                    visible: gruppo.modelData.categorie.length === 1
                                    catId: gruppo.modelData.categorie.length === 1 ? gruppo.modelData.categorie[0] : ""
                                }
                                Repeater {
                                    model: gruppo.modelData.categorie.length > 1 ? gruppo.modelData.categorie : []
                                    Acc {
                                        id: sub
                                        required property var modelData
                                        width: parent.width
                                        livello: "sub"
                                        titolo: Store.catNome(modelData)
                                        conteggio: Store.quantiVoci([modelData])
                                        aperto: Store.apriCat === modelData
                                        onToggle: { Store.apriCat = aperto ? "" : modelData; Store.apriVoce = "" }
                                        corpo: Component { CorpoCategoria { catId: sub.modelData } }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // + Voce libera
            Item { width: 1; height: 12 }
            AutoGrid {
                id: grigliaLibera
                width: parent.width
                minimo: 210; spazio: 8
                Item {
                    implicitHeight: 64
                    scale: lm.pressed ? 0.97 : 1
                    Rectangle { anchors.fill: parent; radius: 10; color: Theme.panel2 }
                    Tratteggio { anchors.fill: parent; raggio: 10; colore: lm.containsMouse ? Theme.line2 : Theme.line }
                    Caps { anchors.centerIn: parent; text: "+ Voce libera"; dimensione: 12; spaziatura: 0.12; color: Theme.muted }
                    MouseArea { id: lm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Store.voceLibera() }
                }
            }
        }
    }
}
