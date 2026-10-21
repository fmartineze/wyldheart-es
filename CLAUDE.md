# wyldheart-es — notas para desarrollo

Mod de traducción al español de Wyldheart Demo (Steam, Unreal Engine 5.6 con IoStore, proyecto interno "Kauri").
Repo público: https://github.com/fmartineze/wyldheart-es

## Cómo funciona
- Los textos del juego están en `Kauri-Windows.pak` (índice sin cifrar, compresión Oodle) como
  `Kauri/Content/Localization/{Game,LocalSave,Lyra,Offline,Script,Settings}/<cultura>/*.locres` (locres v3).
- `scripts/locres.py` exporta/importa locres; `scripts/merge.py` aplica `translations/es_<Target>*.txt`
  (formato `índice<TAB>texto`, `\r\n` = salto de línea) y avisa si no coinciden `{variables}` o `<etiquetas>`.
- `scripts/build.sh` extrae los locres en inglés del juego del usuario, aplica traducciones y genera
  `dist/zz_Spanish_P.pak/.utoc/.ucas`. `scripts/package.py <versión>` crea el zip de la Release.
- El instalador (`install/install.ps1`, lanzado por `Instalar.bat`) busca el juego en las bibliotecas de Steam
  y copia los 3 archivos a `Kauri\Content\Paks\~mods`.

## Descubrimientos no obvios
- Sustituir la cultura `en` no tiene efecto (el motor no carga el locres del idioma nativo):
  el español va en el hueco de `fr` y el jugador elige "français".
- Un `.pak` suelto en `~mods` se ignora: hacen falta `.utoc/.ucas` generados con `retoc to-zen --version UE5_6`.
- Usar repak v0.2.3 (carga Oodle sola); v0.2.2 falla con "oo2core_9_win64.dll not found".
- No subir al repo textos ni archivos originales del juego (copyright): solo traducciones y scripts.

## Publicar versión nueva
`sh scripts/build.sh` → `python scripts/package.py vX.Y.Z` → `gh release create vX.Y.Z dist/Wyldheart-ES-vX.Y.Z.zip`

## Pendiente: juego completo
Cuando salga la versión final hay que adaptar el mod:
- Nombre de carpeta en Steam distinto de "Wyldheart Demo" (build.sh e install.ps1).
- Posible cambio de versión de UE (parámetro `--version` de retoc; ver `retoc info` del `.utoc` del juego).
- Targets de localización nuevos o distintos (ver `LocalizationPaths` en `Kauri/Config/DefaultGame.ini` del pak).
- Las traducciones van por índice de la tabla de cadenas, que cambiará: reasignarlas buscando por el
  texto original en inglés en vez de por índice, y traducir solo lo nuevo.
- Comprobar si el juego final permite añadir el español como cultura propia en vez de usar `fr`.
