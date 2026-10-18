import QtQuick
import QtQuick.Effects

// Pagina iniziale: le foto del locale scorrono dietro il logo, sotto i riquadri Tavoli e Menu
Item {
    id: home

    /* ---------- Slideshow: la foto nuova entra in dissolvenza SOPRA quella vecchia ---------- */
    property int slideIdx: 0
    readonly property var foto: Store.bar.foto

    function mostraSlide(i) {
        const n = slides.count;
        if (!n) return;
        const next = (i + n) % n;
        let prev = null;
        for (let k = 0; k < n; k++) if (slides.itemAt(k).stato === 1) prev = slides.itemAt(k);
        if (prev === slides.itemAt(next)) return;
        for (let k = 0; k < n; k++) if (slides.itemAt(k).stato === 2) slides.itemAt(k).azzera();
        if (prev) { prev.stato = 2; prev.z = 1; uscita.target = prev; uscita.restart() }
        slides.itemAt(next).entra();
        slideIdx = next;
    }
    function avviaSlide() { giro.restart() }

    Timer { id: giro; interval: 5000; repeat: true; running: home.foto.length > 1; onTriggered: home.mostraSlide(home.slideIdx + 1) }
    Timer { id: uscita; property var target: null; interval: 1700; onTriggered: if (target && target.stato === 2) target.azzera() }
    Component.onCompleted: Qt.callLater(function () { mostraSlide(0) })

    Rectangle { anchors.fill: parent; color: "#000000" }
    Item {
        id: fondo
        anchors.fill: parent
        clip: true
        layer.enabled: true
        layer.effect: MultiEffect { blurEnabled: true; blurMax: 8; blur: 0.45 }
        Repeater {
            id: slides
            model: home.foto
            Image {
                id: im
                property int stato: 0   // 0 nascosta, 1 entra/visibile, 2 coperta dalla successiva
                anchors.fill: parent
                source: backend.asset(modelData)
                fillMode: Image.PreserveAspectCrop
                asynchronous: false
                smooth: true
                opacity: 0
                z: 0
                function entra() {
                    entrata.stop(); zoom.stop();
                    opacity = 0; scale = 1; z = 2; stato = 1;
                    entrata.start(); zoom.start();
                }
                function azzera() { entrata.stop(); zoom.stop(); opacity = 0; scale = 1; z = 0; stato = 0 }
                NumberAnimation { id: entrata; target: im; property: "opacity"; to: 1; duration: 1600; easing.type: Easing.InOutQuad }
                NumberAnimation { id: zoom; target: im; property: "scale"; to: 1.08; duration: 7000 }
            }
        }
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(21 / 255, 20 / 255, 31 / 255, 0.55) }
            GradientStop { position: 0.30; color: Qt.rgba(21 / 255, 20 / 255, 31 / 255, 0.45) }
            GradientStop { position: 0.62; color: Qt.rgba(21 / 255, 20 / 255, 31 / 255, 0.82) }
            GradientStop { position: 0.92; color: Theme.night }
            GradientStop { position: 1.0; color: Theme.night }
        }
    }

    /* ---------- Logo e scritte ---------- */
    Item {
        id: sopra
        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: schede.top; topMargin: 48; bottomMargin: 40 }
        Column {
            anchors.centerIn: parent
            spacing: 0
            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.max(180, Math.min(home.width * 0.22, 280, sopra.height - 110))
                height: width
                Image {
                    id: logo
                    anchors.fill: parent
                    source: backend.asset(Store.bar.logo)
                    fillMode: Image.PreserveAspectFit
                    smooth: true; mipmap: true
                    visible: false
                }
                MultiEffect {
                    anchors.fill: logo
                    source: logo
                    shadowEnabled: true
                    shadowColor: Qt.rgba(0, 0, 0, 0.6)
                    shadowVerticalOffset: 10
                    shadowBlur: 1.0
                    blurMax: 40
                    autoPaddingEnabled: true
                }
            }
            Item { width: 1; height: 24 }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 14
                Rectangle { anchors.verticalCenter: parent.verticalCenter; width: 36; height: 2; color: Theme.red }
                Caps { text: Store.bar.sottotitolo; color: Theme.cream }
                Rectangle { anchors.verticalCenter: parent.verticalCenter; width: 36; height: 2; color: Theme.red }
            }
            Item { width: 1; height: 10 }
            T {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.muted
                font.pixelSize: 13
                font.letterSpacing: 0.78
                text: Store.bar.luogo + " · " + Qt.locale("it_IT").toString(new Date(Store.ora), "dddd d MMMM")
            }
            Item { width: 1; height: 18; visible: home.foto.length > 1 }
            Row {
                visible: home.foto.length > 1
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8
                Repeater {
                    model: home.foto.length
                    Rectangle {
                        readonly property bool on: index === home.slideIdx
                        width: on ? 22 : 7; height: 7
                        radius: on ? 4 : 3.5
                        color: on ? Theme.cream : Qt.rgba(1, 1, 1, 0.3)
                        Behavior on width { NumberAnimation { duration: 300 } }
                        MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor; onClicked: { home.mostraSlide(index); home.avviaSlide() } }
                    }
                }
            }
        }
    }

    /* ---------- Riquadri ---------- */
    Row {
        id: schede
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 48 }
        readonly property real larghezza: Math.min(1180, home.width) - 40
        spacing: 16
        Repeater {
            model: [
                { k: "Sala", h: "Tavoli", vai: "tavoli" },
                { k: "Gestione", h: "Modifica menu", vai: "menu" },
                { k: "Menu cartaceo", h: "Visualizza menu", vai: "pdf" }
            ]
            Rectangle {
                id: card
                width: (schede.larghezza - 32) / 3
                height: 200 // uguale per tutti: i titoli su due righe hanno spazio sopra il testo in basso
                radius: 14
                color: Qt.rgba(34 / 255, 33 / 255, 52 / 255, 0.82)
                border.color: ma.containsMouse ? Theme.cream : Theme.line2
                Behavior on border.color { ColorAnimation { duration: 150 } }
                scale: ma.pressed ? 0.98 : 1
                T {
                    anchors { right: parent.right; top: parent.top; rightMargin: 22; topMargin: 6 }
                    text: "›"; font.pixelSize: 32; font.weight: Font.Light; color: Theme.muted
                }
                Column {
                    id: contenuto
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 24 }
                    spacing: 6
                    Caps { text: modelData.k; color: Theme.cream }
                    T {
                        width: parent.width - 30
                        text: modelData.h
                        wrapMode: Text.WordWrap
                        lineHeight: 0.95
                        font.pixelSize: 34; font.weight: Font.ExtraBold
                        font.capitalization: Font.AllUppercase
                        font.letterSpacing: -0.38
                        topPadding: 2
                    }
                }
                T {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: 24; rightMargin: 24; bottomMargin: 22 }
                    wrapMode: Text.WordWrap
                    color: Theme.muted
                    font.pixelSize: 14
                    textFormat: Text.RichText
                    text: {
                        Store.rev;
                        const b = function (x) { return "<span style=\"color:" + Theme.white + ";font-size:20px;font-weight:700\">" + x + "</span>" };
                        if (modelData.vai === "tavoli") {
                            const n = Store.tavoli.length;
                            return n ? b(n) + " " + Store.plurale(n, "aperto", "aperti") + " · " + b(Store.euro(Store.totaleAperti())) + " da incassare"
                                     : "Nessun tavolo aperto";
                        }
                        if (modelData.vai === "pdf") return "Il menu del locale in PDF · " + b("14") + " pagine";
                        const agg = Store.dataMenu();
                        return b(Store.menu.drinks.length) + " voci · prezzi e prodotti" + (agg ? " · aggiornato il " + Store.esc(agg) : "");
                    }
                }
                MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Store.vai(modelData.vai) }
            }
        }
    }
}
