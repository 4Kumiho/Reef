"""
Trasforma il menu cartaceo (desktop/menu-cartaceo.pdf) nelle immagini mostrate da «Visualizza menu».

Da rilanciare solo quando cambia il PDF:   python desktop\\menu_pdf.py "percorso\\del\\nuovo menu.pdf"
(senza argomenti usa desktop/menu-cartaceo.pdf). Poi ricrea l'eseguibile con desktop\\build.ps1.
Serve PyMuPDF:   pip install pymupdf
"""
import sys
from pathlib import Path

import pymupdf

DESKTOP = Path(__file__).resolve().parent
PDF = DESKTOP / "menu-cartaceo.pdf"
CARTELLA = DESKTOP / "assets" / "menu-cartaceo"
LARGHEZZA = 1400  # pixel: nitido anche a tutto schermo


def main() -> None:
    sorgente = Path(sys.argv[1]) if len(sys.argv) > 1 else PDF
    doc = pymupdf.open(sorgente)
    if sorgente.resolve() != PDF.resolve():
        # tiene una copia leggera del PDF nella repo (immagini ricompresse, doppioni tolti)
        doc.rewrite_images(dpi_threshold=200, dpi_target=150, quality=80)
        doc.save(PDF, garbage=4, deflate=True, clean=True)
        doc = pymupdf.open(PDF)
    CARTELLA.mkdir(parents=True, exist_ok=True)
    for vecchia in CARTELLA.glob("pagina-*.jpg"):
        vecchia.unlink()
    for i, pagina in enumerate(doc, start=1):
        zoom = LARGHEZZA / pagina.rect.width
        pix = pagina.get_pixmap(matrix=pymupdf.Matrix(zoom, zoom))
        pix.save(CARTELLA / f"pagina-{i:02d}.jpg", jpg_quality=85)
    print(f"{doc.page_count} pagine in {CARTELLA}")


if __name__ == "__main__":
    main()
