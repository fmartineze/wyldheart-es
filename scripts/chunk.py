"""Split <Name>.json into chunk files of "index<TAB>text" lines (\\n escaped).

Usage: python chunk.py <json> <out_dir> [max_chars]
"""
import json
import os
import sys

src, out = sys.argv[1], sys.argv[2]
limit = int(sys.argv[3]) if len(sys.argv) > 3 else 9000
os.makedirs(out, exist_ok=True)
rows = json.load(open(src, encoding="utf-8"))
n, buf, size = 0, [], 0


def flush():
    global n, buf, size
    open(os.path.join(out, "c%02d.txt" % n), "w", encoding="utf-8").write("\n".join(buf) + "\n")
    n, buf, size = n + 1, [], 0


for r in rows:
    line = "%d\t%s" % (r["i"], r["en"].replace("\r", "\\r").replace("\n", "\\n"))
    buf.append(line)
    size += len(line)
    if size > limit:
        flush()
if buf:
    flush()
print(n, "chunks")
