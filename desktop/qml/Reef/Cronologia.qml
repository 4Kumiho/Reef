pragma Singleton
import QtQuick

// Cronologia: tavoli chiusi, incassi per serata, prodotti più venduti.
// Una «serata» va dalle 8:00 alle 7:59 del giorno dopo: un tavolo pagato all'1:30 di notte conta
// nella serata del giorno prima. Contano anche gli incassi dei tavoli ancora aperti.
QtObject {
    id: c

    readonly property int oraCambio: 8
    readonly property var loc: Qt.locale("it_IT")

    property var voci: []          // tavoli chiusi (dati/cronologia/*.json)
    property bool caricata: false
    property int rev: 0

    /* ---------- Stato della sezione ---------- */
    property string pagina: "serate"   // tavoli | serate | prodotti
    property string tipo: "settimana"  // serata | settimana | mese | anno | tutto
    property double rif: Date.now()    // un momento dentro il periodo scelto
    property string cerca: ""
    property string ordine: "pezzi"    // prodotti: pezzi | incasso
    property string gruppo: ""         // prodotti: filtro per gruppo del menu ("" = tutti)

    function carica() {
        if (caricata) return;
        let v = [];
        try { v = JSON.parse(backend.leggiCronologia()) } catch (e) {}
        voci = Array.isArray(v) ? v : [];
        caricata = true;
        rev++;
    }
    function aggiungi(voce) { if (caricata) { voci.push(voce); rev++ } }
    function elimina(id) {
        if (!backend.eliminaDaCronologia(id)) return false;
        voci = voci.filter(function (v) { return v.id !== id });
        rev++;
        return true;
    }

    /* ---------- Serate e periodi ---------- */
    // la serata di un istante, come data a mezzanotte (es. venerdì 17 per l'1:30 di sabato 18)
    function giornoSerata(ts) { const d = new Date(ts - oraCambio * 3600000); return new Date(d.getFullYear(), d.getMonth(), d.getDate()) }
    function chiave(d) { return d.getFullYear() * 10000 + (d.getMonth() + 1) * 100 + d.getDate() }
    function serataDi(ts) { return chiave(giornoSerata(ts)) }
    function daChiave(k) { return new Date(Math.floor(k / 10000), Math.floor(k / 100) % 100 - 1, k % 100) }
    function piu(d, giorni) { return new Date(d.getFullYear(), d.getMonth(), d.getDate() + giorni) }

    function intervallo() {
        const b = giornoSerata(rif);
        if (tipo === "serata") return { da: b, a: b };
        if (tipo === "settimana") { const lun = piu(b, -((b.getDay() + 6) % 7)); return { da: lun, a: piu(lun, 6) } }
        if (tipo === "mese") return { da: new Date(b.getFullYear(), b.getMonth(), 1), a: new Date(b.getFullYear(), b.getMonth() + 1, 0) };
        if (tipo === "anno") return { da: new Date(b.getFullYear(), 0, 1), a: new Date(b.getFullYear(), 11, 31) };
        const tutti = tuttiIncassi();
        const primo = tutti.length ? daChiave(tutti[0].s) : b;
        return { da: primo, a: giornoSerata(Date.now()) };
    }
    function dentro(k, iv) { return k >= chiave(iv.da) && k <= chiave(iv.a) }
    function imposta(nuovoTipo) { tipo = nuovoTipo; rif = Date.now() }
    function sposta(n) {
        const b = giornoSerata(rif);
        let d;
        if (tipo === "serata") d = piu(b, n);
        else if (tipo === "settimana") d = piu(b, 7 * n);
        else if (tipo === "mese") d = new Date(b.getFullYear(), b.getMonth() + n, 1);
        else if (tipo === "anno") d = new Date(b.getFullYear() + n, 0, 1);
        else return;
        rif = new Date(d.getFullYear(), d.getMonth(), d.getDate(), 12).getTime();
    }
    function apriSerata(k) { tipo = "serata"; const d = daChiave(k); rif = new Date(d.getFullYear(), d.getMonth(), d.getDate(), 12).getTime() }
    function puoAvanti() { return tipo !== "tutto" && chiave(intervallo().a) < serataDi(Date.now()) }
    function puoIndietro() { return tipo !== "tutto" }
    function etichettaSerata(k) {
        const d = daChiave(k);
        const oggi = serataDi(Date.now());
        const nome = loc.toString(d, "dddd d MMMM yyyy");
        return k === oggi ? nome + " · stasera" : k === serataDi(Date.now() - 86400000) ? nome + " · ieri" : nome;
    }
    function etichetta() {
        const iv = intervallo();
        if (tipo === "serata") return etichettaSerata(chiave(iv.da));
        if (tipo === "settimana") {
            const stessoMese = iv.da.getMonth() === iv.a.getMonth();
            return loc.toString(iv.da, stessoMese ? "d" : "d MMMM") + " – " + loc.toString(iv.a, "d MMMM yyyy");
        }
        if (tipo === "mese") { const t = loc.toString(iv.da, "MMMM yyyy"); return t.charAt(0).toUpperCase() + t.slice(1) }
        if (tipo === "anno") return String(iv.da.getFullYear());
        return "Tutto il periodo";
    }

    /* ---------- Dati ---------- */
    // tutti gli incassi (tavoli chiusi + tavoli ancora aperti), in ordine di tempo; s = chiave della serata
    function tuttiIncassi() {
        const out = [];
        const da = function (t, aperto) {
            (t.incassi || []).forEach(function (i) {
                if (i.s === undefined) i.s = serataDi(i.ts);
                out.push({ ts: i.ts, s: i.s, cent: i.cent, righe: i.righe, tavolo: t, aperto: aperto });
            });
        };
        voci.forEach(function (v) { da(v, false) });
        Store.tavoli.forEach(function (t) { da(t, true) });
        out.sort(function (x, y) { return x.ts - y.ts });
        return out;
    }
    function incassiPeriodo() {
        const iv = intervallo();
        return tuttiIncassi().filter(function (i) { return dentro(i.s, iv) });
    }
    function totaleTavolo(v) { return (v.incassi || []).reduce(function (n, i) { return n + i.cent }, 0) }
    function pezziTavolo(v) {
        return (v.incassi || []).reduce(function (n, i) { return n + i.righe.reduce(function (m, r) { return m + r.qty }, 0) }, 0);
    }
    function durata(ms) {
        const min = Math.max(0, Math.round(ms / 60000));
        return min < 60 ? min + " min" : Math.floor(min / 60) + " h " + (min % 60) + " min";
    }

    function riepilogo() {
        const inc = incassiPeriodo();
        const tavoli = {}, serate = {};
        let cent = 0;
        inc.forEach(function (i) {
            cent += i.cent;
            tavoli[i.tavolo.id] = true;
            serate[i.s] = (serate[i.s] || 0) + i.cent;
        });
        const nTavoli = Object.keys(tavoli).length;
        const chiavi = Object.keys(serate);
        let migliore = null;
        chiavi.forEach(function (k) { if (!migliore || serate[k] > migliore.cent) migliore = { k: +k, cent: serate[k] } });
        // ora di punta (per la singola serata)
        const ore = {};
        inc.forEach(function (i) { const h = new Date(i.ts).getHours(); ore[h] = (ore[h] || 0) + i.cent });
        let punta = null;
        Object.keys(ore).forEach(function (h) { if (!punta || ore[h] > punta.cent) punta = { h: +h, cent: ore[h] } });
        return {
            cent: cent, tavoli: nTavoli, serate: chiavi.length,
            mediaTavolo: nTavoli ? Math.round(cent / nTavoli) : 0,
            mediaSerata: chiavi.length ? Math.round(cent / chiavi.length) : 0,
            migliore: migliore, punta: punta
        };
    }

    // barre del grafico: per ora (serata), per serata (settimana, mese), per mese (anno, tutto)
    function serie() {
        const inc = incassiPeriodo();
        const iv = intervallo();
        const barre = [];
        if (tipo === "serata") {
            for (let k = 0; k < 24; k++) {
                const h = (oraCambio + k) % 24;
                barre.push({ etichetta: String(h), titolo: (h < 10 ? "0" : "") + h + ":00 – " + (h < 10 ? "0" : "") + h + ":59", cent: 0 });
            }
            inc.forEach(function (i) { barre[(new Date(i.ts).getHours() - oraCambio + 24) % 24].cent += i.cent });
            return { titolo: "Incasso per ora", barre: barre };
        }
        if (tipo === "settimana" || tipo === "mese") {
            const pos = {};
            for (let d = iv.da; d <= iv.a; d = piu(d, 1)) {
                pos[chiave(d)] = barre.length;
                barre.push({
                    etichetta: tipo === "settimana" ? loc.toString(d, "ddd d") : String(d.getDate()),
                    titolo: etichettaSerata(chiave(d)), cent: 0, serata: chiave(d)
                });
            }
            inc.forEach(function (i) { if (pos[i.s] !== undefined) barre[pos[i.s]].cent += i.cent });
            return { titolo: "Incasso per serata", barre: barre };
        }
        // per mese
        const pos = {};
        for (let m = new Date(iv.da.getFullYear(), iv.da.getMonth(), 1); m <= iv.a; m = new Date(m.getFullYear(), m.getMonth() + 1, 1)) {
            pos[m.getFullYear() * 100 + m.getMonth()] = barre.length;
            const nome = loc.toString(m, "MMMM yyyy");
            barre.push({
                etichetta: tipo === "anno" ? loc.toString(m, "MMM") : loc.toString(m, "MMM yy"),
                titolo: nome.charAt(0).toUpperCase() + nome.slice(1), cent: 0, mese: m.getTime()
            });
        }
        inc.forEach(function (i) {
            const d = daChiave(i.s);
            const p = pos[d.getFullYear() * 100 + d.getMonth()];
            if (p !== undefined) barre[p].cent += i.cent;
        });
        return { titolo: "Incasso per mese", barre: barre };
    }

    function classificaSerate() {
        const inc = incassiPeriodo();
        const m = {};
        inc.forEach(function (i) {
            if (!m[i.s]) m[i.s] = { k: i.s, cent: 0, tavoli: {} };
            m[i.s].cent += i.cent;
            m[i.s].tavoli[i.tavolo.id] = true;
        });
        return Object.keys(m).map(function (k) { const x = m[k]; return { k: x.k, cent: x.cent, tavoli: Object.keys(x.tavoli).length } })
            .sort(function (a, b) { return b.cent - a.cent });
    }

    // tavoli chiusi del periodo (per serata di apertura), raggruppati per serata, dal più recente
    function gruppiTavoli() {
        const iv = intervallo();
        const q = Store.norm(cerca.trim());
        const scelti = voci.filter(function (v) {
            if (v.s === undefined) v.s = serataDi(v.aperto);
            if (!dentro(v.s, iv)) return false;
            if (!q) return true;
            if (Store.norm(v.nome).indexOf(q) >= 0) return true;
            return v.incassi.some(function (i) { return i.righe.some(function (r) { return Store.norm(r.nome).indexOf(q) >= 0 }) });
        }).sort(function (a, b) { return b.chiuso - a.chiuso });
        const gruppi = [];
        scelti.forEach(function (v) {
            let g = gruppi.length ? gruppi[gruppi.length - 1] : null;
            if (!g || g.k !== v.s) { g = { k: v.s, tavoli: [], cent: 0 }; gruppi.push(g) }
            g.tavoli.push(v);
            g.cent += totaleTavolo(v);
        });
        return gruppi;
    }
    // prodotti venduti nel tavolo, sommando gli incassi
    function prodottiTavolo(v) {
        const m = {}, ordine = [];
        (v.incassi || []).forEach(function (i) {
            i.righe.forEach(function (r) {
                const k = r.nome + "|" + r.prezzoCent;
                if (!m[k]) { m[k] = { nome: r.nome, prezzoCent: r.prezzoCent, qty: 0 }; ordine.push(k) }
                m[k].qty += r.qty;
            });
        });
        return ordine.map(function (k) { return m[k] });
    }

    // gruppo del menu di una categoria (per il filtro dei prodotti)
    function gruppoDi(cat) {
        const g = Store.gruppi().find(function (x) { return x.categorie.indexOf(cat) >= 0 });
        return g ? g.id : "";
    }
    function prodotti() {
        const m = {};
        incassiPeriodo().forEach(function (i) {
            i.righe.forEach(function (r) {
                const cat = r.categoria || (r.drinkId && Store.drinkById(r.drinkId) ? Store.drinkById(r.drinkId).categoria : "");
                if (gruppo && gruppoDi(cat) !== gruppo) return;
                if (!m[r.nome]) m[r.nome] = { nome: r.nome, drinkId: r.drinkId, qty: 0, cent: 0, emoji: "" };
                m[r.nome].qty += r.qty;
                m[r.nome].cent += r.qty * r.prezzoCent;
            });
        });
        const lista = Object.keys(m).map(function (k) {
            const p = m[k];
            const d = p.drinkId ? Store.drinkById(p.drinkId) : null;
            p.emoji = d && d.emoji ? d.emoji : "🧾";
            return p;
        });
        const chiaveOrdine = ordine === "incasso" ? "cent" : "qty";
        lista.sort(function (a, b) { return b[chiaveOrdine] - a[chiaveOrdine] || b.cent - a.cent || a.nome.localeCompare(b.nome) });
        return lista;
    }
    // voci del menu mai vendute nel periodo (rispettando il filtro per gruppo)
    function maiVenduti(venduti) {
        const ids = {};
        venduti.forEach(function (p) { if (p.drinkId) ids[p.drinkId] = true });
        return Store.menu.drinks.filter(function (d) {
            return !ids[d.id] && (!gruppo || gruppoDi(d.categoria) === gruppo);
        });
    }

    /* ---------- Per la pagina iniziale ---------- */
    function stasera() {
        const oggi = serataDi(Date.now());
        let cent = 0;
        const tavoli = {};
        tuttiIncassi().forEach(function (i) { if (i.s === oggi) { cent += i.cent; tavoli[i.tavolo.id] = true } });
        return { cent: cent, tavoli: Object.keys(tavoli).length };
    }
}
