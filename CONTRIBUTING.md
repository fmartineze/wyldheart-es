# Colaborar con la traducción

¡Gracias por querer ayudar! Aquí se explica cómo está organizado el proyecto, cómo corregir textos y cómo compilar el mod.

## Corregir o mejorar textos

Los textos están en [`translations/`](translations/), repartidos en varios ficheros. Cada línea tiene este formato:

```
índice<TAB>texto traducido
```

- El **índice** es la posición del texto en el archivo de idioma original del juego. No lo cambies.
- `\r\n` representa un salto de línea.
- Mantén intactas las variables y etiquetas: `{0}`, `{Value}`, `{item}`, `<highlight>…</>`, `<OBJ>…</>`, `<img id="…"/>`, `(#confirm ...)`, `(#clear)`, `(#delay 1)`.
- Si una línea no existe, ese texto se queda en inglés.
- Los textos que empiezan por espacio (p. ej. `" no está interesado"`) se pegan detrás de un nombre de personaje. Conserva el espacio inicial.

### Criterios de estilo

- Tuteo al jugador.
- Los nombres propios de personajes y pueblos se mantienen en inglés (Alrik, Gael, Pim, Elderlight, Rivermere, Whisperwood…).
- Los lugares con nombre descriptivo se traducen (Tumba Podrida, Fortaleza Marchita, Cueva Trollcap).
- Los textos de menús deben ser cortos, porque el espacio en pantalla es limitado.

Envía tus cambios con un *pull request*, o abre un [issue](https://github.com/fmartineze/wyldheart-es/issues) con la corrección.

## Compilar el mod

Requisitos: Windows, [Git Bash](https://git-scm.com/), Python 3 y el juego instalado.

```sh
sh scripts/build.sh                                   # usa la ruta de Steam por defecto
sh scripts/build.sh "D:/SteamLibrary/steamapps/common/Wyldheart Demo" --install
python scripts/package.py v1.0.0                      # crea dist/Wyldheart-ES-v1.0.0.zip
```

`--install` copia el resultado a la carpeta `~mods` del juego para probarlo.

### Qué hace `build.sh`

1. Descarga [repak](https://github.com/trumank/repak) y [retoc](https://github.com/trumank/retoc) en `tools/`.
2. Extrae los textos originales en inglés (`Kauri/Content/Localization/*/en/*.locres`) de **tu copia** del juego.
3. Aplica las traducciones (`scripts/locres.py`, `scripts/merge.py`) y avisa si alguna variable o etiqueta no coincide con el original.
4. Genera `dist/zz_Spanish_P.pak` junto con `.utoc` y `.ucas`.

### Detalles técnicos

- El juego usa Unreal Engine 5.6 con IoStore. Ignora un `.pak` de mod que no venga acompañado de sus archivos `.utoc`/`.ucas`.
- El motor no carga traducciones para el idioma nativo (inglés), así que el español se instala en el hueco del francés (`fr`).
- El repositorio no incluye textos ni archivos originales del juego: se extraen de la copia de cada usuario al compilar.

## Estructura del repositorio

```
translations/   textos traducidos (es_<Target>*.txt)
scripts/        compilación del mod y empaquetado de la Release
install/        instalador (Instalar.bat, Desinstalar.bat, install.ps1) y LEEME.txt del zip
```
