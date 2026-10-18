/*
 * Impostazioni dell'app Staff.
 * Il MENU (voci, prezzi, varianti) è in shared/menu.json e si modifica dall'app (sezione Menu).
 */
window.REEF = {
  bar: {
    nome: "Reef Café",
    sottotitolo: "Rock 'n' Roll · Drink 'n' Dine",
    luogo: "Borgo Santa Caterina 25 · Bergamo",
    logo: "../shared/logo.png",
    // foto che scorrono nella pagina iniziale
    foto: [
      "../shared/img/bancone.jpg",
      "../shared/img/sala-vinili.jpg",
      "../shared/img/parete.jpg",
      "../shared/img/esterno.jpg",
    ],
  },

  // Dove l'app pubblica le modifiche al menu (repository GitHub che ospita l'app)
  github: { owner: "4Kumiho", repo: "Reef", branch: "main", menuPath: "shared/menu.json" },
};
