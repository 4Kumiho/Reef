"""
Reef Café · Staff — app desktop (Python + Qt/QML).

Questo file avvia la finestra e si occupa solo dei file:
- i tavoli e il menu sono salvati in JSON nella cartella «dati» accanto all'eseguibile
  (se la cartella non è scrivibile, in %LOCALAPPDATA%\\Reef Staff\\dati);
- al primo avvio il menu parte dalla copia predefinita (desktop/assets/menu.json).
L'interfaccia e tutta la logica dell'app sono in qml/Reef/.
"""
import ctypes
import json
import os
import sys
from datetime import datetime
from pathlib import Path

import PySide6

# i plugin QML di Qt trovano le loro DLL solo se la cartella di PySide6 è tra quelle di sistema
if sys.platform == "win32" and os.path.isdir(os.path.dirname(PySide6.__file__)):
    os.add_dll_directory(os.path.dirname(PySide6.__file__))

from PySide6.QtCore import QLockFile, QObject, QtMsgType, QUrl, Slot, qInstallMessageHandler
from PySide6.QtGui import QFontDatabase, QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuick import QQuickWindow

NOME_APP = "Reef Staff"

# RADICE contiene desktop/qml (interfaccia) e desktop/assets (logo, foto, font, menu predefinito),
# con la stessa struttura della repo: dentro l'eseguibile oppure la repo stessa.
if getattr(sys, "frozen", False):
    RADICE = Path(sys._MEIPASS)
    CARTELLA_APP = Path(sys.executable).resolve().parent
else:
    RADICE = Path(__file__).resolve().parent.parent
    CARTELLA_APP = RADICE
DESKTOP = RADICE / "desktop"
ASSETS = DESKTOP / "assets"


def cartella_scrivibile(p: Path) -> bool:
    try:
        p.mkdir(parents=True, exist_ok=True)
        prova = p / ".prova-scrittura"
        prova.write_text("ok", encoding="utf-8")
        prova.unlink()
        return True
    except OSError:
        return False


def cartella_dati() -> Path:
    if os.environ.get("REEF_DATI"):  # per le prove
        p = Path(os.environ["REEF_DATI"])
        p.mkdir(parents=True, exist_ok=True)
        return p
    vicino = CARTELLA_APP / "dati"
    if cartella_scrivibile(vicino):
        return vicino
    altrove = Path(os.environ.get("LOCALAPPDATA", Path.home())) / NOME_APP / "dati"
    altrove.mkdir(parents=True, exist_ok=True)
    return altrove


def avviso(titolo: str, testo: str) -> None:
    if sys.platform == "win32":
        ctypes.windll.user32.MessageBoxW(None, testo, titolo, 0x40)
    else:
        print(f"{titolo}: {testo}", file=sys.stderr)


def registro_errori(dati: Path) -> None:
    """Avvisi ed errori di Qt/QML finiscono in dati/errori.log (utile per capire un problema sul PC del locale)."""
    log = dati / "errori.log"

    def scrivi(tipo, contesto, messaggio):
        if tipo == QtMsgType.QtDebugMsg or tipo == QtMsgType.QtInfoMsg:
            return
        try:
            if log.exists() and log.stat().st_size > 512 * 1024:
                log.unlink()
            with open(log, "a", encoding="utf-8") as f:
                f.write(f"{datetime.now():%Y-%m-%d %H:%M:%S} {messaggio}\n")
        except OSError:
            pass

    qInstallMessageHandler(scrivi)


class Backend(QObject):
    """Lettura e scrittura dei file, chiamate dall'interfaccia QML."""

    def __init__(self, dati: Path):
        super().__init__()
        self.dati = dati

    def _file(self, nome: str) -> Path:
        if nome not in ("tavoli", "menu"):
            raise ValueError(nome)
        return self.dati / f"{nome}.json"

    @Slot(str, result=str)
    def leggi(self, nome: str) -> str:
        """Contenuto di dati/<nome>.json, oppure "" se non c'è ancora."""
        p = self._file(nome)
        for f in (p, p.with_suffix(".json.bak")):
            try:
                testo = f.read_text(encoding="utf-8")
                json.loads(testo)
                return testo
            except (OSError, ValueError):
                continue
        return ""

    @Slot(str, str, result=bool)
    def scrivi(self, nome: str, testo: str) -> bool:
        """Salva in modo sicuro: prima un file temporaneo, poi lo scambio (tiene anche una copia .bak)."""
        p = self._file(nome)
        tmp = p.with_suffix(".json.tmp")
        try:
            with open(tmp, "w", encoding="utf-8", newline="\n") as f:
                f.write(testo)
                f.flush()
                os.fsync(f.fileno())
            if p.exists():
                os.replace(p, p.with_suffix(".json.bak"))
            os.replace(tmp, p)
            return True
        except OSError:
            return False

    @Slot(result=str)
    def menuPredefinito(self) -> str:
        return (ASSETS / "menu.json").read_text(encoding="utf-8")

    @Slot(str, result=str)
    def asset(self, percorso: str) -> str:
        """URL di un file di desktop/assets, es. "logo.png"."""
        return QUrl.fromLocalFile(str(ASSETS / percorso)).toString()

    @Slot(result=list)
    def pagineMenu(self) -> list:
        """Le pagine del menu cartaceo (immagini create da desktop/menu_pdf.py), in ordine."""
        return [QUrl.fromLocalFile(str(f)).toString() for f in sorted((ASSETS / "menu-cartaceo").glob("pagina-*.jpg"))]

    @Slot(result=str)
    def cartellaDati(self) -> str:
        return str(self.dati)

    @Slot(str, str, result=bool)
    def esporta(self, url: str, testo: str) -> bool:
        try:
            Path(QUrl(url).toLocalFile()).write_text(testo, encoding="utf-8")
            return True
        except OSError:
            return False

    @Slot(str, result=str)
    def importa(self, url: str) -> str:
        try:
            return Path(QUrl(url).toLocalFile()).read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError):
            return ""


def main() -> int:
    if sys.platform == "win32":
        # icona giusta sulla barra delle applicazioni
        ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID("ReefCafe.Staff")

    # testo nitido come nel browser (DirectWrite)
    QQuickWindow.setTextRenderType(QQuickWindow.TextRenderType.NativeTextRendering)
    app = QGuiApplication(sys.argv)
    app.setApplicationName(NOME_APP)
    app.setOrganizationName("Reef Café")
    app.setWindowIcon(QIcon(str(ASSETS / "icon.png")))

    dati = cartella_dati()
    # Una sola finestra alla volta: due copie aperte si sovrascriverebbero i tavoli
    blocco = QLockFile(str(dati / ".in-uso.lock"))
    blocco.setStaleLockTime(0)
    if not blocco.tryLock(100):
        avviso(NOME_APP, "Reef Staff è già aperto.\nCercalo sulla barra delle applicazioni.")
        return 0

    if getattr(sys, "frozen", False):
        registro_errori(dati)

    for ttf in sorted(ASSETS.glob("Montserrat-*.ttf")):
        QFontDatabase.addApplicationFont(str(ttf))

    backend = Backend(dati)
    engine = QQmlApplicationEngine()
    engine.addImportPath(str(DESKTOP / "qml"))
    engine.rootContext().setContextProperty("backend", backend)
    engine.load(QUrl.fromLocalFile(str(DESKTOP / "qml" / "Main.qml")))
    if not engine.rootObjects():
        avviso(NOME_APP, "Impossibile avviare l'interfaccia.")
        return 1
    codice = app.exec()
    # prima si chiude l'interfaccia, poi il backend che usa (altrimenti QML lo trova già distrutto)
    del engine
    blocco.unlock()
    return codice


if __name__ == "__main__":
    sys.exit(main())
