pragma Singleton
import QtQuick

// Collegamento alle finestre e agli avvisi, che vivono in Main.qml (host).
QtObject {
    property var host: null

    function toast(msg) { host.toast(msg) }
    // apre una finestra (file Dlg<nome>.qml) con le proprietà indicate; fatto(valore) viene chiamato alla conferma
    function apri(nome, props, fatto) { return host.apriFinestra(nome, props || {}, fatto || null) }
    function chiudi(valore) { host.chiudiFinestra(valore === undefined ? null : valore) }
    function blocca() { host.finestraBloccata = true }

    function conferma(opts, fatto) { apri("Conferma", opts, fatto) }
    function chiedi(opts, fatto) { apri("Chiedi", opts, fatto) }
    function messaggio(titolo, testo) { apri("Messaggio", { titolo: titolo, testo: testo }) }

    // porta in vista un elemento della pagina (scorrendo con un'animazione)
    function mostra(item) { host.mostraElemento(item) }
}
