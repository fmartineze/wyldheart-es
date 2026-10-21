"""Create the release zip from dist/ (run scripts/build.sh first).

Usage: python scripts/package.py <version>   ->  dist/Wyldheart-ES-<version>.zip
"""
import os
import sys
import zipfile

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
version = sys.argv[1]
top = "Wyldheart-ES-%s" % version
out = os.path.join(root, "dist", top + ".zip")

entries = [
    ("install/Instalar.bat", "Instalar.bat"),
    ("install/Desinstalar.bat", "Desinstalar.bat"),
    ("install/install.ps1", "install.ps1"),
    ("install/LEEME.txt", "LEEME.txt"),
]
entries += [("dist/zz_Spanish_P" + ext, "mod/zz_Spanish_P" + ext) for ext in (".pak", ".utoc", ".ucas")]

with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    for src, dst in entries:
        z.write(os.path.join(root, src), top + "/" + dst)
print(out)
