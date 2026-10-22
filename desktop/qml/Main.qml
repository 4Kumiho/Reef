import QtQuick
import QtQuick.Window
import QtQuick.Controls.Basic
import QtQuick.Effects
import Reef

Window {
    id: win
    width: 1440; height: 900
    minimumWidth: 980; minimumHeight: 640
    visible: true
    visibility: Window.Maximized
    title: Store.bar.nome + " · Staff"
    color: Theme.night

    Component.onCompleted: {
        Ui.host = win;
        Store.avvia();
        Cronologia.carica();
    }

    // Aggiorna i tempi "aperto da…" ogni 30 secondi
    Timer { interval: 30000; repeat: true; running: true; onTriggered: Store.ora = Date.now() }

    /* ---------- Sfondo (.rf-bg) ---------- */
    Canvas {
        id: sfondo
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const c = getContext("2d"), w = width, h = height;
            c.reset();
            c.fillStyle = "#15141f";
            c.fillRect(0, 0, w, h);
            function ellisse(cx, cy, rx, ry, r, g, b, a) {
                c.save();
                c.translate(cx, cy);
                c.scale(rx, ry);
                const gr = c.createRadialGradient(0, 0, 0, 0, 0, 1);
                gr.addColorStop(0, "rgba(" + r + "," + g + "," + b + "," + a + ")");
                gr.addColorStop(0.7, "rgba(" + r + "," + g + "," + b + ",0)");
                c.fillStyle = gr;
                c.fillRect(-cx / rx, -cy / ry, w / rx, h / ry);
                c.restore();
            }
            ellisse(w * 0.5, -0.1 * h, 0.8 * w, 0.5 * h, 163, 72, 73, 0.16);
            ellisse(w, h, 0.6 * w, 0.4 * h, 235, 196, 133, 0.05);
        }
    }

    /* ---------- Pagine ---------- */
    Loader {
        anchors.fill: parent
        active: Store.view === "home"
        sourceComponent: HomeView {}
    }

    Flickable {
        id: pagina
        anchors.fill: parent
        visible: Store.view !== "home"
        contentWidth: width
        contentHeight: contenuto.y + pageLoader.height + 24
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        ScrollBar.vertical: ScrollBar {
            visible: pagina.contentHeight > pagina.height + 1
            topPadding: Theme.topH + 2
            contentItem: Rectangle { implicitWidth: 6; radius: 3; color: Theme.line2 }
        }
        Behavior on contentY { enabled: scorri.attivo; NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

        Item {
            id: contenuto
            x: (pagina.width - width) / 2
            y: Theme.topH + 24
            width: Math.min(1440, pagina.width) - 48
            Loader {
                id: pageLoader
                width: parent.width
                sourceComponent: Store.view === "tavoli" ? cTavoli
                               : Store.view === "tavolo" ? cTavolo
                               : Store.view === "menu" ? cMenu
                               : Store.view === "pdf" ? cPdf
                               : Store.view === "cronologia" ? cCrono : null
            }
        }
    }
    Component { id: cTavoli; TavoliView {} }
    Component { id: cTavolo; TavoloView { scrollY: pagina.contentY; viewTop: contenuto.y; altezzaFinestra: win.height } }
    Component { id: cMenu; MenuView {} }
    Component { id: cPdf; PdfView {} }
    Component { id: cCrono; CronologiaView {} }

    Connections {
        target: Store
        function onNavigato() {
            scorri.attivo = false;
            pagina.contentY = 0;
            chiavi.forceActiveFocus();
        }
    }

    TopBar {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        visible: Store.view !== "home"
    }

    // porta in vista un elemento della pagina (es. il gruppo appena aperto nel menu del tavolo)
    QtObject { id: scorri; property bool attivo: false; property var item: null }
    Timer {
        id: scorriTimer
        interval: 40
        onTriggered: {
            const it = scorri.item;
            if (!it || !pagina.visible) return;
            const p = it.mapToItem(pagina.contentItem, 0, 0);
            const alto = pagina.contentY + Theme.topH + 16, basso = pagina.contentY + pagina.height - 16;
            let y = pagina.contentY;
            if (p.y + it.height > basso) y += p.y + it.height - basso;
            if (p.y - y < Theme.topH + 16) y = p.y - Theme.topH - 16;
            y = Math.max(0, Math.min(y, pagina.contentHeight - pagina.height));
            scorri.attivo = true;
            pagina.contentY = y;
            fineScorri.restart();
        }
    }
    Timer { id: fineScorri; interval: 300; onTriggered: scorri.attivo = false }
    function mostraElemento(item) { scorri.item = item; scorriTimer.restart() }

    /* ---------- Tastiera ---------- */
    Item { id: chiavi; focus: true }
    Shortcut {
        sequence: "Esc"
        enabled: overlay.aperta && !win.finestraBloccata
        onActivated: win.chiudiFinestra(null)
    }
    Shortcut {
        sequences: ["N", "Shift+N"]
        enabled: !overlay.aperta && (Store.view === "tavoli" || Store.view === "home")
        onActivated: Store.nuovoTavolo()
    }
    // Cronologia: frecce ← → per il periodo precedente / successivo
    Shortcut {
        sequence: "Left"
        enabled: !overlay.aperta && Store.view === "cronologia" && Cronologia.puoIndietro()
        onActivated: Cronologia.sposta(-1)
    }
    Shortcut {
        sequence: "Right"
        enabled: !overlay.aperta && Store.view === "cronologia" && Cronologia.puoAvanti()
        onActivated: Cronologia.sposta(1)
    }
    // zoom di «Visualizza menu» con + e −
    Shortcut {
        sequences: ["+", "=", "Ctrl++"]
        enabled: !overlay.aperta && Store.view === "pdf" && !!pageLoader.item
        onActivated: pageLoader.item.zoom(1)
    }
    Shortcut {
        sequences: ["-", "Ctrl+-"]
        enabled: !overlay.aperta && Store.view === "pdf" && !!pageLoader.item
        onActivated: pageLoader.item.zoom(-1)
    }
    Shortcut {
        sequence: "/"
        enabled: !overlay.aperta && (Store.view === "tavolo" || Store.view === "menu" || Store.view === "cronologia") && !!pageLoader.item
        onActivated: pageLoader.item.focusRicerca()
    }

    /* ---------- Finestre (dialoghi) ---------- */
    property bool finestraBloccata: false
    property var risolvi: null

    function apriFinestra(nome, props, fatto) {
        risolvi = null;
        finestraBloccata = false;
        dlg.setSource(Qt.resolvedUrl("Reef/Dlg" + nome + ".qml"), props);
        risolvi = fatto;
        finestraBloccata = !!(dlg.item && dlg.item.bloccata);
        boxFlick.contentY = 0;
        overlay.aperta = true;
        return dlg.item;
    }
    function chiudiFinestra(valore) {
        finestraBloccata = false;
        overlay.aperta = false;
        chiavi.forceActiveFocus();
        const r = risolvi;
        risolvi = null;
        svuota.restart();
        if (r && valore !== null && valore !== undefined) r(valore);
    }
    Timer { id: svuota; interval: 200; onTriggered: if (!overlay.aperta) dlg.source = "" }

    Rectangle {
        id: overlay
        property bool aperta: false
        anchors.fill: parent
        color: Qt.rgba(8 / 255, 8 / 255, 14 / 255, 0.75)
        opacity: aperta ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: if (!win.finestraBloccata) win.chiudiFinestra(null)
            onWheel: function (w) { w.accepted = true }
        }
        Rectangle {
            id: box
            anchors.centerIn: parent
            readonly property real massima: dlg.item && dlg.item.formato === "small" ? 440 : dlg.item && dlg.item.formato === "wide" ? 780 : 560
            width: Math.min(massima, overlay.width - 32)
            height: Math.min(dlg.height, overlay.height - 32)
            radius: 16
            color: Theme.coal
            border.color: Theme.line2
            MouseArea { anchors.fill: parent; hoverEnabled: true }
            Flickable {
                id: boxFlick
                anchors.fill: parent
                contentHeight: dlg.height
                clip: true
                interactive: contentHeight > height
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { visible: boxFlick.contentHeight > boxFlick.height + 1; contentItem: Rectangle { implicitWidth: 6; radius: 3; color: Theme.line2 } }
                Loader {
                    id: dlg
                    width: box.width
                    height: item ? item.implicitHeight : 0
                }
            }
        }
    }

    /* ---------- Avviso in basso (.toast) ---------- */
    function toast(msg) {
        toastTesto.text = msg;
        toastBox.mostra = true;
        toastTimer.restart();
    }
    Timer { id: toastTimer; interval: 2200; onTriggered: toastBox.mostra = false }
    Item {
        id: toastBox
        property bool mostra: false
        anchors.horizontalCenter: parent.horizontalCenter
        width: toastTesto.implicitWidth + 44 + 4
        height: toastTesto.implicitHeight + 28
        y: win.height - 24 - height + (mostra ? 0 : 20)
        opacity: mostra ? 1 : 0
        visible: opacity > 0
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        Rectangle {
            id: toastFondo
            anchors.fill: parent
            radius: 10
            color: Theme.red
            visible: false
        }
        MultiEffect {
            anchors.fill: toastFondo
            source: toastFondo
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.5)
            shadowVerticalOffset: 10
            shadowBlur: 0.8
            blurMax: 30
            autoPaddingEnabled: true
        }
        Rectangle {
            anchors { fill: parent; leftMargin: 4 }
            color: Theme.white
            topLeftRadius: 6; bottomLeftRadius: 6
            topRightRadius: 10; bottomRightRadius: 10
        }
        T {
            id: toastTesto
            x: 4 + 22
            anchors.verticalCenter: parent.verticalCenter
            font.weight: Font.Bold
            color: Theme.night
        }
    }
}
