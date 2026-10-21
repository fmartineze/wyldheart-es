# Wyldheart Demo — Traducción al español

Traducción **no oficial** al español de la demo de [Wyldheart](https://wyldheartgame.com) (Steam).
Traduce menús, opciones, diálogos, misiones, notas, objetos, habilidades, enemigos y lugares (~4.200 textos).

> 🇬🇧 *Unofficial Spanish translation mod for the Wyldheart Demo. Download the latest release, run `Instalar.bat`, then set the in-game language to **français**.*

## Instalación (fácil)

1. Descarga el zip de la [última versión](https://github.com/fmartineze/wyldheart-es/releases/latest) y descomprímelo.
2. Cierra el juego y haz doble clic en **`Instalar.bat`**.
   - Encuentra el juego automáticamente en tus bibliotecas de Steam.
   - Si no lo encuentra, te pedirá que elijas la carpeta `Wyldheart Demo`.
3. En el juego: **Options → GAMEPLAY → Language → `français`**.
4. Reinicia el juego.

> **¿Por qué "français"?** Unreal Engine no carga traducciones para el idioma original del juego (inglés), así que el español ocupa el hueco del francés.

### Desinstalar

Doble clic en **`Desinstalar.bat`** y vuelve a poner el idioma en *English*.

### Instalación manual

Copia los tres archivos de la carpeta `mod` del zip (`zz_Spanish_P.pak`, `.utoc`, `.ucas`) a:

```
...\steamapps\common\Wyldheart Demo\Kauri\Content\Paks\~mods\
```

Crea la carpeta `~mods` si no existe. Para desinstalar, bórrala.

## Notas

- Los nombres propios de personajes y pueblos (Alrik, Gael, Elderlight, Rivermere, Whisperwood…) se mantienen en inglés.
- Algunas frases del juego se construyen pegando un nombre delante (p. ej. *"Faelan" + " no está interesado"*), por lo que puede haber algún fallo de género.
- Si el juego se actualiza y aparecen textos raros o en francés, la traducción puede necesitar actualizarse. [Abre un issue](https://github.com/fmartineze/wyldheart-es/issues).
- Los archivos originales del juego no se modifican.

## Corregir o mejorar la traducción

Los textos están en [`translations/`](translations/), un fichero por bloque, con el formato:

```
índice<TAB>texto traducido
```

- `\r\n` representa un salto de línea.
- Respeta las etiquetas y variables: `{0}`, `{Value}`, `<highlight>…</>`, `<img id="…"/>`, `(#confirm ...)`, `(#clear)`.
- El índice es la posición del texto en el archivo `.locres` original. Una línea sin traducir deja el texto en inglés.

Se aceptan *pull requests* con correcciones.

## Compilar el mod

Requisitos: Windows, [Git Bash](https://git-scm.com/), Python 3 y el juego instalado.

```sh
sh scripts/build.sh                                  # usa la ruta de Steam por defecto
sh scripts/build.sh "D:/SteamLibrary/steamapps/common/Wyldheart Demo" --install
python scripts/package.py v1.0.0                     # crea dist/Wyldheart-ES-v1.0.0.zip
```

El script:

1. Descarga [repak](https://github.com/trumank/repak) y [retoc](https://github.com/trumank/retoc) en `tools/`.
2. Extrae los textos en inglés (`Localization/*/en/*.locres`) de **tu copia** del juego.
3. Aplica las traducciones (`scripts/locres.py`, `scripts/merge.py`) y comprueba que las variables y etiquetas coinciden.
4. Empaqueta el resultado en `dist/zz_Spanish_P.pak` + `.utoc`/`.ucas`. El juego usa IoStore (UE 5.6) e ignora un `.pak` de mod sin esos dos archivos.

## Aviso legal

Proyecto de fans sin relación con los desarrolladores ni el editor de Wyldheart. Wyldheart y todo su contenido pertenecen a sus respectivos propietarios. Este repositorio no incluye archivos ni textos originales del juego: solo las traducciones y las herramientas para aplicarlas.

El código y las traducciones de este repositorio se publican bajo licencia [MIT](LICENSE).
