# PyInstaller: crea «Reef Staff.exe» (un solo file) nella radice della repo.
# Si lancia con desktop\build.ps1
import re
from pathlib import Path

RADICE = Path(SPECPATH).parent

datas = [
    (str(RADICE / "desktop" / "qml"), "desktop/qml"),
    (str(RADICE / "desktop" / "assets"), "desktop/assets"),
]

a = Analysis(
    [str(RADICE / "desktop" / "main.py")],
    pathex=[],
    binaries=[],
    datas=datas,
    hiddenimports=["PySide6.QtQuick", "PySide6.QtQml"],
    excludes=["tkinter", "unittest", "pydoc", "PySide6.QtSql", "PySide6.QtTest", "PySide6.QtXml", "PySide6.QtDBus",
              "PySide6.QtPrintSupport"],
    noarchive=False,
)

# Toglie le parti di Qt che l'app non usa (stili dei controlli non usati, moduli QML non usati,
# rendering OpenGL software): l'eseguibile resta molto più piccolo.
INUTILI = re.compile(r"""(
      opengl32sw\.dll
    | Qt6(Designer|Pdf|Quick3D|3D|Charts|DataVisualization|Graphs|Multimedia|WebEngine|WebChannel|WebSockets|
          Location|Positioning|Sensors|SerialPort|Bluetooth|Nfc|RemoteObjects|Scxml|StateMachine|TextToSpeech|
          VirtualKeyboard|Test|QuickTest|Sql|Help|UiTools|SpatialAudio|PrintSupport|
          QuickControls2(Material|Universal|Imagine|FluentWinUI3))\w*\.dll
    | [\\/]qml[\\/](QtQuick3D|Qt3D|QtCharts|QtDataVisualization|QtGraphs|QtMultimedia|QtWebEngine|QtWebChannel|
          QtWebSockets|QtLocation|QtPositioning|QtSensors|QtTest|QtTextToSpeech|QtScxml|QtRemoteObjects|
          QtQuick[\\/](VirtualKeyboard|Scene2D|Scene3D|Particles|Timeline|Pdf|LocalStorage|
          NativeStyle|tooling)|QtQuick[\\/]Controls[\\/](Material|Universal|Imagine|FluentWinUI3|designer))
    | [\\/]translations[\\/](?!qt_it|qtbase_it|qtdeclarative_it)
)""", re.X | re.I)
a.binaries = [b for b in a.binaries if not INUTILI.search(b[0]) and not INUTILI.search(b[1])]
a.datas = [d for d in a.datas if not INUTILI.search(d[0]) and not INUTILI.search(d[1])]

pyz = PYZ(a.pure)
exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name="Reef Staff",
    icon=str(RADICE / "desktop" / "assets" / "icon.ico"),
    console=False,
    debug=False,
    strip=False,
    upx=False,
    version=None,
)
