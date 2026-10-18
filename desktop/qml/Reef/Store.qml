pragma Singleton
import QtQuick

// Dati dell'app (tavoli e menu), stato dell'interfaccia e tutte le azioni.
// I file si leggono e si scrivono tramite «backend» (main.py): dati/tavoli.json e dati/menu.json.
QtObject {
    id: s

    readonly property var bar: ({
        nome: "Reef Café",
        sottotitolo: "Rock 'n' Roll · Drink 'n' Dine",
        luogo: "Borgo Santa Caterina 25 · Bergamo",
        logo: "logo.png",
        // foto che scorrono nella pagina iniziale
        foto: ["img/bancone.jpg", "img/sala.jpg", "img/spine.jpg", "img/sala-rossa.jpg",
               "img/bancone-2.jpg", "img/divanetti.jpg", "img/corridoio.jpg", "img/sala-2.jpg"]
    })
    // versione del menu incluso nell'app (desktop/assets/menu.json): prima di una modifica
    // dall'app non si mostra "aggiornato il…"
    property string menuIniziale: ""

    property var menu: ({ gruppi: [], categorie: [], drinks: [] })
    property var tavoli: []
    property int rev: 0        // cambia a ogni modifica dei tavoli
    property int payRev: 0     // cambia a ogni modifica della selezione «paga separato»
    property double ora: Date.now() // aggiornato ogni 30 secondi (tempi «aperto da…»)

    /* ---------- Navigazione ---------- */
    property string view: "home"   // home | tavoli | tavolo | menu
    property string tavoloId: ""
    signal navigato()

    /* ---------- Stato interfaccia ---------- */
    property string pickQ: ""
    property string apriGruppo: ""
    property string apriCat: ""
    property string apriVoce: ""
    property string meQ: ""
    property string meCat: "tutti"
    property var pagamento: null   // { id: tavoloId, sel: { rigaId: quantità } }

    function vai(v, id) {
        if (v === "tavolo" && !tavoloById(id)) v = "tavoli";
        pagamento = null;
        pickQ = "";
        tavoloId = v === "tavolo" ? id : "";
        view = v;
        navigato();
    }

    /* ---------- Utilità ---------- */
    function norm(t) {
        t = String(t === undefined || t === null ? "" : t);
        if (t.normalize) t = t.normalize("NFD").replace(/[̀-ͯ]/g, "");
        return t.toLowerCase();
    }
    function uid() { return Date.now().toString(36) + Math.random().toString(36).slice(2, 7) }
    function clona(o) { return JSON.parse(JSON.stringify(o)) }
    // come Intl.NumberFormat("it-IT", { style: "currency", currency: "EUR" })
    function euro(c) {
        c = Math.round(c);
        const neg = c < 0;
        c = Math.abs(c);
        let e = String(Math.floor(c / 100));
        if (e.length > 4) e = e.replace(/\B(?=(\d{3})+(?!\d))/g, ".");
        const d = c % 100;
        return (neg ? "-" : "") + e + "," + (d < 10 ? "0" : "") + d + " €";
    }
    function cent(p) { return Math.round(p * 100) }
    function esc(t) {
        return String(t === undefined || t === null ? "" : t).replace(/[&<>"']/g, function (c) {
            return ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c];
        });
    }
    function numero(v) { const n = parseFloat(String(v).replace(",", ".").trim()); return isFinite(n) ? n : NaN }
    function prezzoTxt(p) { return p === undefined || p === null ? "" : String(p).replace(".", ",") }
    function plurale(n, uno, tanti) { return n === 1 ? uno : tanti }

    /* ---------- Avvio e salvataggio ---------- */
    function menuValido(m) { return !!(m && Array.isArray(m.categorie) && Array.isArray(m.drinks)) }
    function avvia() {
        const predefinito = JSON.parse(backend.menuPredefinito());
        menuIniziale = predefinito.versione || "";
        let m = null;
        try { m = JSON.parse(backend.leggi("menu") || "null") } catch (e) {}
        // il menu salvato vale solo se deriva dal menu incluso in questa versione dell'app (campo «base»):
        // così un aggiornamento dell'app con un menu nuovo lo porta anche sul computer del bar
        if (!menuValido(m) || m.base !== menuIniziale) m = predefinito;
        menu = m;
        let t = [];
        try { t = JSON.parse(backend.leggi("tavoli") || "[]") } catch (e) {}
        tavoli = Array.isArray(t) ? t : [];
    }
    function salva() {
        rev++;
        if (!backend.scrivi("tavoli", JSON.stringify(tavoli)))
            Ui.messaggio("Attenzione", "Impossibile salvare i dati sul computer.");
    }
    // salva il menu nel file locale; restituisce un messaggio d'errore oppure ""
    function salvaMenu(nuovo) {
        nuovo.versione = new Date().toISOString();
        nuovo.base = menuIniziale;
        if (!backend.scrivi("menu", JSON.stringify(nuovo, null, 2) + "\n"))
            return "Salvataggio non riuscito: la cartella dei dati non è scrivibile.";
        menu = nuovo;
        rev++;
        return "";
    }
    function dataMenu() {
        const v = menu && menu.versione;
        if (!v || v === menuIniziale) return "";
        return Qt.locale("it_IT").toString(new Date(v), "d MMMM 'alle' HH:mm");
    }

    /* ---------- Menu ---------- */
    function drinkById(id) { return menu.drinks.find(function (d) { return d.id === id }) }
    function catById(id) { return menu.categorie.find(function (c) { return c.id === id }) || {} }
    function catNome(id) { return catById(id).nome || "" }
    function varNome(v) { return typeof v === "string" ? v : v.nome }
    function varPrezzo(d, v) { return typeof v === "object" && v.prezzo !== undefined && v.prezzo !== null ? v.prezzo : d.prezzo }
    function varInfo(v) { return typeof v === "object" && v.info ? v.info : "" }
    function prezzoLabel(d) {
        const ps = (d.varianti || []).map(function (v) { return varPrezzo(d, v) });
        const min = ps.length ? Math.min.apply(null, ps) : d.prezzo;
        if (!min && !ps.some(function (p) { return p })) return "Omaggio";
        return (ps.some(function (p) { return p !== ps[0] }) ? "da " : "") + euro(cent(min));
    }
    // nome mostrato sul bottone dentro il menu a tendina (l'etichetta, se c'è, è il nome breve: es. "Spina")
    function titoloVoce(d) { return d.etichetta || d.nome }
    function nomeRiga(d, i) { return i === null || i === undefined ? d.nome : d.nome + " · " + varNome(d.varianti[i]) }
    // Ogni prodotto ordinabile: le voci senza varianti, oppure ogni singola variante
    function prodotti(d) {
        if (!d.varianti || !d.varianti.length) return [{ d: d, i: null, nome: d.nome, info: "", prezzo: d.prezzo }];
        return d.varianti.map(function (v, i) { return { d: d, i: i, nome: varNome(v), info: varInfo(v), prezzo: varPrezzo(d, v) } });
    }
    function filtra(lista, q, cat) {
        const nq = norm(q.trim());
        return lista.filter(function (d) {
            if (nq) return norm([d.nome, d.descrizione || ""].concat((d.varianti || []).map(varNome)).join(" ")).indexOf(nq) >= 0;
            return cat === "tutti" || d.categoria === cat;
        });
    }
    /* Gruppi del menu a tendina (es. Paninoteca → Panini Rock, Toast & co.).
       Le categorie non assegnate a un gruppo diventano un gruppo a sé. */
    function gruppi() {
        const esiste = function (id) { return menu.categorie.some(function (c) { return c.id === id }) };
        const lista = (menu.gruppi || [])
            .map(function (g) { return Object.assign({}, g, { categorie: g.categorie.filter(esiste) }) })
            .filter(function (g) { return g.categorie.length });
        const usate = {};
        lista.forEach(function (g) { g.categorie.forEach(function (c) { usate[c] = true }) });
        menu.categorie.filter(function (c) { return !usate[c.id] })
            .forEach(function (c) { lista.push({ id: "cat-" + c.id, nome: c.nome, categorie: [c.id] }) });
        return lista;
    }
    function quantiVoci(catIds) {
        return menu.drinks.filter(function (d) { return catIds.indexOf(d.categoria) >= 0 }).reduce(function (n, d) {
            return n + (catById(d.categoria).scelta ? 1 : prodotti(d).length);
        }, 0);
    }
    // Contenuto di una categoria nel menu a tendina:
    // - categoria "scelta" (es. Panini Rock): un bottone per voce, poi si sceglie il formato
    // - categoria "a tendina": ogni voce si apre e mostra le sue varianti
    // - voci semplici e voci con poche varianti → bottoni col nome completo
    // - voci con tante varianti (spritz, gin, amari…) → in fondo, con un titoletto e sotto le varianti
    function corpoCategoria(catId) {
        const voci = menu.drinks.filter(function (d) { return d.categoria === catId });
        const cat = catById(catId);
        if (!voci.length) return { tipo: "vuota" };
        if (cat.scelta) return { tipo: "scelta", bottoni: voci.map(function (d) { return { d: d, i: null, titolo: titoloVoce(d), voce: true } }) };
        if (cat.tendina) return { tipo: "tendina", voci: voci };
        const tante = function (d) { return d.varianti && d.varianti.length > 3 };
        const semplici = [];
        voci.filter(function (d) { return !tante(d) }).forEach(function (d) {
            prodotti(d).forEach(function (p) {
                semplici.push({ d: p.d, i: p.i, titolo: p.i === null ? titoloVoce(p.d) : titoloVoce(p.d) + " · " + p.nome });
            });
        });
        const gruppetti = voci.filter(tante).map(function (d) {
            return { titolo: titoloVoce(d), bottoni: prodotti(d).map(function (p) { return { d: p.d, i: p.i, titolo: p.nome } }) };
        });
        return { tipo: "normale", bottoni: semplici, gruppetti: gruppetti };
    }
    function bottoniVoceTendina(d) {
        return prodotti(d).map(function (p) { return { d: d, i: p.i, titolo: p.i === null ? titoloVoce(d) : p.nome } });
    }
    // Ricerca dentro un tavolo: trova qualsiasi prodotto, anche le singole varianti
    function cerca(q) {
        q = norm(q.trim());
        const out = [];
        menu.drinks.forEach(function (d) {
            prodotti(d).forEach(function (p) {
                if (norm([p.d.nome, p.nome, p.info, p.d.descrizione || "", catNome(p.d.categoria)].join(" ")).indexOf(q) >= 0)
                    out.push({ d: p.d, i: p.i, titolo: nomeRiga(p.d, p.i) });
            });
        });
        return out;
    }
    // Il primo prodotto visibile nell'elenco (Invio nella ricerca lo aggiunge)
    function primoProdotto() {
        if (pickQ.trim()) return cerca(pickQ)[0] || null;
        const g = gruppi().find(function (x) { return x.id === apriGruppo });
        if (!g) return null;
        const catId = g.categorie.length > 1 ? apriCat : g.categorie[0];
        if (!catId) return null;
        const c = corpoCategoria(catId);
        if (c.tipo === "scelta") return c.bottoni[0];
        if (c.tipo === "tendina") { const d = drinkById(apriVoce); return d && d.categoria === catId ? bottoniVoceTendina(d)[0] : null }
        if (c.tipo === "normale") return c.bottoni[0] || (c.gruppetti[0] && c.gruppetti[0].bottoni[0]) || null;
        return null;
    }

    /* ---------- Tavoli ---------- */
    function tavoloById(id) { return tavoli.find(function (t) { return t.id === id }) }
    function tavolo() { return tavoloById(tavoloId) || null }
    function totale(t) { return t.righe.reduce(function (n, r) { return n + r.qty * r.prezzoCent }, 0) }
    function pezzi(t) { return t.righe.reduce(function (n, r) { return n + r.qty }, 0) }
    function totaleAperti() { return tavoli.reduce(function (n, t) { return n + totale(t) }, 0) }
    function tempo(ts) {
        const min = Math.floor((ora - ts) / 60000);
        const h = Qt.formatTime(new Date(ts), "HH:mm");
        const da = min < 1 ? "adesso" : min < 60 ? "da " + min + " min" : "da " + Math.floor(min / 60) + " h " + (min % 60) + " min";
        return "aperto alle " + h + " · " + da;
    }
    // Propone il primo "Tavolo N" libero, così basta premere Invio
    function propostaNome() {
        for (let n = 1; ; n++) {
            const nome = "Tavolo " + n;
            if (!tavoli.some(function (t) { return norm(t.nome) === norm(nome) })) return nome;
        }
    }
    function validaNome(nome, escludiId) {
        const n = (nome || "").trim();
        if (!n) return "Scrivi un nome.";
        if (tavoli.some(function (t) { return t.id !== escludiId && norm(t.nome) === norm(n) })) return "Esiste già un tavolo aperto con questo nome.";
        return "";
    }
    // quanti pezzi di un prodotto (o di una voce, con tutte le varianti) ci sono nell'ordine
    function quanti(t, drinkId, nome) {
        if (!t) return 0;
        return t.righe.filter(function (r) { return r.drinkId === drinkId && (nome === null || r.nome === nome) })
            .reduce(function (n, r) { return n + r.qty }, 0);
    }
    function aggiungiRiga(t, drinkId, nome, prezzoCent) {
        const r = t.righe.find(function (x) { return x.drinkId === drinkId && x.nome === nome && x.prezzoCent === prezzoCent });
        if (r) r.qty++;
        else t.righe.push({ id: uid(), drinkId: drinkId, nome: nome, prezzoCent: prezzoCent, qty: 1 });
        salva();
    }
    function eliminaTavolo(t) {
        tavoli = tavoli.filter(function (x) { return x.id !== t.id });
        salva();
        Ui.toast("Tavolo «" + t.nome + "» chiuso");
        vai("tavoli");
    }

    /* ---------- Azioni ---------- */
    function nuovoTavolo() {
        Ui.chiedi({
            titolo: "Nuovo tavolo",
            campi: [{ name: "nome", label: "Nome del tavolo", placeholder: "es. Tavolo 4, Bancone, Esterno 2…", value: propostaNome() }],
            ok: "Crea tavolo",
            valida: function (v) { return validaNome(v.nome) }
        }, function (v) {
            const t = { id: uid(), nome: v.nome.trim(), creato: Date.now(), righe: [] };
            tavoli.push(t);
            salva();
            vai("tavolo", t.id);
        });
    }
    // clic su un prodotto (i = variante, oppure null): le voci con varianti aprono la scelta
    function aggiungi(d, i) {
        const t = tavolo();
        if (!t || !d) return false;
        if ((i === null || i === undefined) && d.varianti && d.varianti.length) {
            Ui.apri("Variante", { voce: d });
            return false;
        }
        const nome = nomeRiga(d, i);
        aggiungiRiga(t, d.id, nome, cent(i === null || i === undefined ? d.prezzo : varPrezzo(d, d.varianti[i])));
        Ui.toast("+ " + nome);
        return true;
    }
    function aggiungiVariante(d, i) {
        const t = tavolo();
        const v = d && d.varianti && d.varianti[i];
        if (!t || !v) return;
        const nome = d.nome + " · " + varNome(v);
        Ui.chiudi(null);
        aggiungiRiga(t, d.id, nome, cent(varPrezzo(d, v)));
        Ui.toast("+ " + nome);
    }
    function voceLibera() {
        const t = tavolo();
        if (!t) return;
        Ui.chiedi({
            titolo: "Voce libera",
            campi: [
                { name: "nome", label: "Descrizione", placeholder: "es. Shot speciale, Torta…" },
                { name: "prezzo", label: "Prezzo (€)", placeholder: "es. 3,50", decimale: true }
            ],
            ok: "Aggiungi",
            valida: function (v) {
                if (!v.nome.trim()) return "Scrivi una descrizione.";
                if (!(numero(v.prezzo) >= 0)) return "Prezzo non valido.";
                return "";
            }
        }, function (v) { aggiungiRiga(t, null, v.nome.trim(), Math.round(numero(v.prezzo) * 100)) });
    }
    // le righe arrivano dall'elenco dell'ordine come copie: si cerca quella vera nel tavolo tramite l'id
    function rigaVera(t, r) { return t && r ? t.righe.find(function (x) { return x.id === r.id }) : null }
    function inc(t, r) {
        const x = rigaVera(t, r);
        if (!x) return;
        x.qty++;
        salva();
    }
    function dec(t, r) {
        const x = rigaVera(t, r);
        if (!x) return;
        x.qty--;
        if (x.qty <= 0) t.righe = t.righe.filter(function (y) { return y !== x });
        salva();
    }
    function rinomina(t) {
        Ui.chiedi({
            titolo: "Rinomina tavolo",
            campi: [{ name: "nome", label: "Nome del tavolo", value: t.nome }],
            ok: "Salva",
            valida: function (v) { return validaNome(v.nome, t.id) }
        }, function (v) { t.nome = v.nome.trim(); salva() });
    }
    function chiudiTavolo(t) {
        const tot = totale(t);
        Ui.conferma({
            titolo: "Chiudere «" + t.nome + "»?",
            testo: tot ? "Il tavolo verrà eliminato con tutti gli ordini.<br>Totale da incassare: <b style=\"color:" + Theme.white + "\">" + euro(tot) + "</b>"
                       : "Il tavolo verrà eliminato.",
            ok: tot ? "Pagato " + euro(tot) + " · Chiudi" : "Chiudi tavolo",
            pericolo: true
        }, function () { eliminaTavolo(t) });
    }

    /* Paga separato */
    function paySel(t) { return pagamento && t && pagamento.id === t.id ? pagamento.sel : null }
    function pagaSeparato(t) { pagamento = { id: t.id, sel: {} }; payRev++ }
    function payAnnulla() { pagamento = null; payRev++ }
    function payImposta(r, n) { if (!pagamento) return; pagamento.sel[r.id] = Math.max(0, Math.min(r.qty, n)); payRev++ }
    function payTutto(t) { if (!pagamento) return; t.righe.forEach(function (x) { pagamento.sel[x.id] = x.qty }); payRev++ }
    function payTotale(t) {
        const sel = paySel(t);
        return sel ? t.righe.reduce(function (n, x) { return n + (sel[x.id] || 0) * x.prezzoCent }, 0) : 0;
    }
    function payConferma(t) {
        const sel = paySel(t);
        if (!sel) return;
        const incassato = payTotale(t);
        t.righe.forEach(function (x) { x.qty -= sel[x.id] || 0 });
        t.righe = t.righe.filter(function (x) { return x.qty > 0 });
        pagamento = null;
        payRev++;
        salva();
        Ui.toast("Incassati " + euro(incassato));
        if (!t.righe.length) {
            Ui.conferma({ titolo: "Tavolo saldato", testo: "<b>" + esc(t.nome) + "</b> ha pagato tutto. Vuoi chiudere il tavolo?", ok: "Chiudi tavolo" },
                        function () { eliminaTavolo(t) });
        }
    }

    /* ---------- Gestione menu ---------- */
    function slug(nome) {
        const base = norm(nome).replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "") || "voce";
        let id = base, i = 2;
        while (menu.drinks.some(function (d) { return d.id === id }) || menu.categorie.some(function (c) { return c.id === id })) id = base + "-" + i++;
        return id;
    }
    // campi: { nome, prezzo, categoria, emoji, etichetta, descrizione }; righe: [{ nome, prezzo, info }]
    // restituisce un messaggio d'errore oppure ""
    function salvaVoce(id, campi, righe) {
        const nome = campi.nome.trim();
        if (!nome) return "Scrivi il nome.";
        const prezzo = numero(campi.prezzo);
        if (!(prezzo >= 0)) return "Prezzo non valido (es. 8 oppure 4,50).";
        const varianti = [];
        for (let k = 0; k < righe.length; k++) {
            const r = { nome: righe[k].nome.trim(), prezzo: righe[k].prezzo.trim(), info: righe[k].info.trim() };
            if (!r.nome) continue;
            const o = { nome: r.nome };
            if (r.prezzo) {
                const vp = numero(r.prezzo);
                if (!(vp >= 0)) return "Prezzo non valido nella variante «" + r.nome + "».";
                if (vp !== prezzo) o.prezzo = vp;
            }
            if (r.info) o.info = r.info;
            varianti.push(Object.keys(o).length === 1 ? o.nome : o);
        }
        const vecchia = id ? drinkById(id) : null;
        const voce = vecchia ? Object.assign({}, vecchia) : { id: slug(nome) };
        Object.assign(voce, { nome: nome, categoria: campi.categoria, prezzo: prezzo, emoji: campi.emoji.trim() || "🍺" });
        const extra = { etichetta: campi.etichetta.trim(), descrizione: campi.descrizione.trim() };
        Object.keys(extra).forEach(function (k) { if (extra[k]) voce[k] = extra[k]; else delete voce[k] });
        if (varianti.length) voce.varianti = varianti; else delete voce.varianti;

        const lista = menu.drinks.filter(function (x) { return x.id !== voce.id });
        let pos = vecchia && vecchia.categoria === voce.categoria ? menu.drinks.indexOf(vecchia) : -1;
        if (pos < 0) {
            const ultimo = lista.map(function (x) { return x.categoria }).lastIndexOf(voce.categoria);
            pos = ultimo >= 0 ? ultimo + 1 : lista.length;
        }
        lista.splice(pos, 0, voce);
        const nuovo = clona(menu);
        nuovo.drinks = lista;
        const err = salvaMenu(nuovo);
        if (!err) Ui.toast(vecchia ? "Salvato «" + nome + "»" : "Aggiunto «" + nome + "»");
        return err;
    }
    function eliminaVoce(id) {
        const voce = drinkById(id);
        const nuovo = clona(menu);
        nuovo.drinks = nuovo.drinks.filter(function (x) { return x.id !== id });
        const err = salvaMenu(nuovo);
        if (!err) Ui.toast("Eliminato «" + (voce ? voce.nome : "") + "»");
        return err;
    }
    // righe: [{ id, nome }] nell'ordine voluto (id "" = categoria nuova)
    function salvaCategorie(righe) {
        const nuove = [];
        for (let k = 0; k < righe.length; k++) {
            const nome = righe[k].nome.trim();
            if (!nome) return "Ogni categoria deve avere un nome.";
            if (nuove.some(function (c) { return norm(c.nome) === norm(nome) })) return "La categoria «" + nome + "» è ripetuta.";
            const vecchia = menu.categorie.find(function (c) { return c.id === righe[k].id });
            nuove.push(Object.assign({}, vecchia || {}, { id: righe[k].id || slug(nome), nome: nome }));
        }
        const nuovo = clona(menu);
        nuovo.categorie = nuove;
        const err = salvaMenu(nuovo);
        if (!err) Ui.toast("Categorie salvate");
        return err;
    }
    function testoEsportazione() {
        return JSON.stringify({ app: "reef-staff", tipo: "menu", esportato: new Date().toISOString(),
                                gruppi: menu.gruppi, categorie: menu.categorie, drinks: menu.drinks }, null, 2);
    }
    function nomeEsportazione() { return "menu-reef-" + new Date().toISOString().slice(0, 10) + ".json" }
    // carica una copia del menu (file scaricato con «Scarica copia», oppure un menu.json)
    function importaMenu(testo) {
        let m = null;
        try { m = JSON.parse(testo) } catch (e) {}
        if (!menuValido(m)) { Ui.messaggio("File non valido", "Il file scelto non contiene un menu del Reef Staff."); return }
        Ui.conferma({
            titolo: "Caricare questa copia?",
            testo: "Il menu attuale verrà sostituito con quello del file (<b>" + m.drinks.length + "</b> voci).<br>I tavoli già aperti mantengono i loro prezzi.",
            ok: "Carica menu"
        }, function () {
            const nuovo = { versione: "", gruppi: m.gruppi || menu.gruppi || [], categorie: m.categorie, drinks: m.drinks };
            const err = salvaMenu(nuovo);
            if (err) Ui.messaggio("Errore", err); else Ui.toast("Menu caricato");
        });
    }
    function ripristinaMenu() {
        Ui.conferma({
            titolo: "Ripristinare il menu originale?",
            testo: "Tutte le modifiche fatte al menu verranno perse. Ti conviene prima <b>Scarica copia</b>.",
            ok: "Ripristina", pericolo: true
        }, function () {
            const m = JSON.parse(backend.menuPredefinito());
            const err = salvaMenu(m);
            if (err) Ui.messaggio("Errore", err); else Ui.toast("Menu originale ripristinato");
        });
    }
}
