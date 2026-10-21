#!/bin/sh
# Builds the Spanish mod from your own copy of Wyldheart Demo.
#
# Usage (Git Bash):  sh scripts/build.sh ["C:/path/to/Wyldheart Demo"] [--install]
#
# Output: dist/zz_Spanish_P.pak, .utoc, .ucas
# Requires: Python 3, curl, unzip. repak and retoc are downloaded into tools/.
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GAME="C:/Program Files (x86)/Steam/steamapps/common/Wyldheart Demo"
INSTALL=0
for a in "$@"; do
  case "$a" in
    --install) INSTALL=1 ;;
    *) GAME="$a" ;;
  esac
done
PAK="$GAME/Kauri/Content/Paks/Kauri-Windows.pak"
[ -f "$PAK" ] || { echo "Game pak not found: $PAK"; exit 1; }

REPAK_VER=v0.2.3
RETOC_VER=v0.1.5
TOOLS="$ROOT/tools"
WORK="$ROOT/work"
DIST="$ROOT/dist"
TARGETS="Game LocalSave Offline Script Lyra Settings"
# Spanish goes into the "fr" slot: the engine skips loading the native (en) culture.
CULTURES="fr en"
export PYTHONIOENCODING=utf-8

fetch() { # name url
  if [ ! -f "$TOOLS/$1/$1.exe" ]; then
    echo "Downloading $1..."
    mkdir -p "$TOOLS/$1"
    curl -sSL -o "$TOOLS/$1/dl.zip" "$2"
    unzip -o -q "$TOOLS/$1/dl.zip" -d "$TOOLS/$1"
    rm -f "$TOOLS/$1/dl.zip"
  fi
}
fetch repak "https://github.com/trumank/repak/releases/download/$REPAK_VER/repak_cli-x86_64-pc-windows-msvc.zip"
fetch retoc "https://github.com/trumank/retoc/releases/download/$RETOC_VER/retoc_cli-x86_64-pc-windows-msvc.zip"
REPAK="$TOOLS/repak/repak.exe"
RETOC="$TOOLS/retoc/retoc.exe"

rm -rf "$WORK" "$DIST"
mkdir -p "$WORK/json" "$WORK/zen" "$DIST"

echo "Extracting English texts from the game..."
"$REPAK" unpack -q -o "$WORK/extract" -i "Kauri/Content/Localization/*/en/*.locres" "$PAK"

for n in $TARGETS; do
  src="$WORK/extract/Kauri/Content/Localization/$n/en/$n.locres"
  python -I "$ROOT/scripts/locres.py" export "$src" "$WORK/json/$n.json" >/dev/null
  python -I "$ROOT/scripts/merge.py" "$WORK/json" "$ROOT/translations" "$n"
  for c in $CULTURES; do
    d="$WORK/pak/Kauri/Content/Localization/$n/$c"
    mkdir -p "$d"
    python -I "$ROOT/scripts/locres.py" import "$src" "$WORK/json/$n.json" "$d/$n.locres" >/dev/null
  done
done

"$REPAK" pack --version V11 --mount-point ../../../ "$WORK/pak" "$DIST/zz_Spanish_P.pak"
# UE5 IoStore games ignore a mod .pak without matching .utoc/.ucas files.
"$RETOC" to-zen --version UE5_6 "$DIST/zz_Spanish_P.pak" "$WORK/zen/zz_Spanish_P.utoc"
cp "$WORK/zen/zz_Spanish_P.utoc" "$WORK/zen/zz_Spanish_P.ucas" "$DIST/"
echo "Built: $DIST"

if [ "$INSTALL" = 1 ]; then
  MODS="$GAME/Kauri/Content/Paks/~mods"
  mkdir -p "$MODS"
  cp "$DIST"/zz_Spanish_P.* "$MODS/"
  echo "Installed to $MODS"
fi
