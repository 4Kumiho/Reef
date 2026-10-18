// Rende l'app utilizzabile offline.
// - menu.json: prima dalla rete (per avere sempre il menu più recente), se offline dalla copia salvata
// - tutto il resto: subito dalla copia salvata, e in background scarica l'eventuale versione aggiornata
// Cambiando CACHE, i dispositivi scaricano la nuova versione dell'app e mostrano "Aggiorna".
const CACHE = "reef-staff-v1";
const FILES = [
  "./", "./index.html", "./manifest.json", "./favicon.ico", "./icon-180.png", "./icon-192.png", "./icon-512.png",
  "../shared/config.js", "../shared/menu.json", "../shared/brand.css", "../shared/logo.png",
  "../shared/img/bancone.jpg", "../shared/img/sala-vinili.jpg", "../shared/img/parete.jpg", "../shared/img/esterno.jpg",
  "../shared/fonts/montserrat.woff2",
];

self.addEventListener("install", (e) => {
  e.waitUntil(
    caches.open(CACHE)
      .then((c) => c.addAll(FILES.map((u) => new Request(u, { cache: "reload" }))))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k.startsWith("reef-staff-") && k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (e) => {
  const url = new URL(e.request.url);
  if (e.request.method !== "GET" || url.origin !== location.origin) return;

  if (url.pathname.endsWith("/menu.json")) {
    const chiave = url.origin + url.pathname;
    e.respondWith(
      caches.open(CACHE).then((cache) =>
        fetch(e.request, { cache: "no-store" })
          .then((res) => { if (res.ok) cache.put(chiave, res.clone()); return res; })
          .catch(() => cache.match(chiave))
      )
    );
    return;
  }

  e.respondWith(
    caches.open(CACHE).then(async (cache) => {
      const cached = await cache.match(e.request, { ignoreSearch: true });
      const network = fetch(e.request)
        .then((res) => {
          if (res.ok) cache.put(e.request, res.clone());
          return res;
        })
        .catch(() => cached);
      return cached || network;
    })
  );
});
