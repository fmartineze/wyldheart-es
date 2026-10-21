"""Merge es_<Name>*.txt (lines "index<TAB>text", \\n = newline) into <Name>.json.

Usage: python merge.py <json_dir> <tr_dir> <Name>
Checks that {placeholders} and <tags> match the English source.
"""
import glob
import json
import os
import re
import sys

# {placeholders} and rich-text tags like <highlight>, </>, <img id="x"/> (not "<unknown action>")
TOKENS = re.compile(r"\{[^}|]*\}|<[^>\s]*(?:\s[^>]*=[^>]*)?>")

json_dir, tr_dir, name = sys.argv[1:4]
path = os.path.join(json_dir, name + ".json")
rows = json.load(open(path, encoding="utf-8"))
by_i = {r["i"]: r for r in rows}
count = 0
for f in sorted(glob.glob(os.path.join(tr_dir, "es_%s*.txt" % name))):
    for ln, line in enumerate(open(f, encoding="utf-8").read().split("\n"), 1):
        if not line.strip():
            continue
        idx, _, text = line.partition("\t")
        text = text.replace("\\r", "\r").replace("\\n", "\n")
        r = by_i[int(idx)]
        if sorted(TOKENS.findall(r["en"])) != sorted(TOKENS.findall(text)):
            print("TOKEN MISMATCH %s:%d [%s]\n  en: %r\n  es: %r" % (os.path.basename(f), ln, idx, r["en"], text))
        r["es"] = text
        count += 1
json.dump(rows, open(path, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
missing = [r["i"] for r in rows if not r["es"] and re.search("[A-Za-z]", r["en"])]
print("%s: merged %d, untranslated %d" % (name, count, len(missing)))
