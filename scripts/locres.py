"""Minimal UE .locres (v2/v3) reader/writer.

Usage:
  python locres.py export <file.locres> <out.json>
  python locres.py import <file.locres> <strings.json> <out.locres>

The JSON is a list of {"i": index, "keys": [...], "en": text, "es": text};
strings are edited in place in the string table, so key/hash data is preserved.
A row may also carry "key_es": {"Namespace::Key": text} to give one key of a shared
string its own translation; that key is repointed to a new string-table entry.
"""
import json
import struct
import sys


class Reader:
    def __init__(self, data):
        self.d = data
        self.p = 0

    def take(self, fmt):
        v = struct.unpack_from(fmt, self.d, self.p)
        self.p += struct.calcsize(fmt)
        return v[0]

    def fstring(self):
        n = self.take("<i")
        if n == 0:
            return ""
        if n > 0:
            s = self.d[self.p:self.p + n - 1].decode("latin-1")
            self.p += n
        else:
            n = -n
            s = self.d[self.p:self.p + (n - 1) * 2].decode("utf-16-le", "surrogatepass")
            self.p += n * 2
        return s


def wfstring(s):
    if s == "":
        return struct.pack("<i", 0)
    try:
        b = s.encode("ascii")
        return struct.pack("<i", len(b) + 1) + b + b"\0"
    except UnicodeEncodeError:
        b = s.encode("utf-16-le", "surrogatepass")
        n = len(b) // 2 + 1
        return struct.pack("<i", -n) + b + b"\0\0"


def parse(data):
    r = Reader(data)
    magic = data[:16]
    r.p = 16
    version = r.take("<B")
    assert version in (2, 3), "unsupported locres version %d" % version
    str_off = r.take("<q")
    r.take("<I")  # entries count
    ns_count = r.take("<I")
    keys_by_index = {}
    index_offsets = {}  # "Namespace::Key" -> file offset of its string index
    for _ in range(ns_count):
        r.take("<I")
        ns = r.fstring()
        for _ in range(r.take("<I")):
            r.take("<I")
            key = r.fstring()
            r.take("<I")  # source string hash
            index_offsets[ns + "::" + key] = r.p
            idx = r.take("<i")
            keys_by_index.setdefault(idx, []).append(ns + "::" + key)
    r.p = str_off
    strings = []
    for _ in range(r.take("<i")):
        s = r.fstring()
        rc = r.take("<i")
        strings.append([s, rc])
    return magic, version, index_offsets, str_off, strings, keys_by_index


def export(src, out):
    data = open(src, "rb").read()
    _, version, _, _, strings, kbi = parse(data)
    rows = [{"i": i, "keys": kbi.get(i, []), "en": s, "es": ""} for i, (s, _) in enumerate(strings)]
    json.dump(rows, open(out, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print("version", version, "strings", len(rows))


def do_import(src, tr, out):
    data = open(src, "rb").read()
    _, _, index_offsets, str_off, strings, _ = parse(data)
    rows = json.load(open(tr, encoding="utf-8"))
    trans = {r["i"]: r["es"] for r in rows if r.get("es")}
    header = bytearray(data[:str_off])
    extra = []
    for r in rows:
        for key, text in r.get("key_es", {}).items():
            off = index_offsets[key]
            strings[struct.unpack_from("<i", header, off)[0]][1] -= 1
            struct.pack_into("<i", header, off, len(strings) + len(extra))
            extra.append([text, 1])
    body = struct.pack("<i", len(strings) + len(extra))
    for i, (s, rc) in enumerate(strings):
        body += wfstring(trans.get(i, s)) + struct.pack("<i", rc)
    for s, rc in extra:
        body += wfstring(s) + struct.pack("<i", rc)
    open(out, "wb").write(bytes(header) + body)
    print("translated", len(trans), "of", len(strings), "+", len(extra), "per-key")


if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "export":
        export(sys.argv[2], sys.argv[3])
    elif cmd == "import":
        do_import(sys.argv[2], sys.argv[3], sys.argv[4])
