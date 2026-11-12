#!/usr/bin/env python3
"""Ambil lirik tersinkron dari LRCLIB untuk widget lirik end-4.

Pemakaian: fetch_lyrics.py --artist A --title T [--album X] [--duration detik]
Output: satu baris JSON ke stdout.
"""
import argparse
import hashlib
import json
import os
import re
import time
import urllib.error
import urllib.parse
import urllib.request

API = "https://lrclib.net/api"
UA = "ii-lyrics/1.0 (end-4 desktop widget)"
CACHE = os.path.join(os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache")), "ii-lyrics")
NOTFOUND_TTL = 24 * 3600

NOISE = re.compile(
    r"(?i)\b(official\s*(music\s*)?(video|audio|mv|lyric\s*video)|music\s*video|lyrics?\s*video|"
    r"video\s*(lirik|klip|musik)|lirik\s*lagu|lyrics?|lirik|visuali[sz]er|audio|hd|hq|4k|mv|m/v)\b"
)


def clean(text):
    text = re.sub(r"[\(\[\{【「][^\)\]\}】」]*[\)\]\}】」]", " ", text)
    text = re.sub(r"(?i)\s(ft\.?|feat\.?|featuring)\s.*$", "", text)
    text = NOISE.sub(" ", text)
    text = re.sub(r"[^\w\s\-'&.,!?]", " ", text)
    text = re.sub(r"\s+", " ", text)
    return text.strip(" -|.,")


def split_artist_title(artist, title):
    """YouTube sering memakai format 'Artis - Judul' dengan artis = nama channel."""
    t = clean(title)
    for sep in (" - ", " – ", " — ", " | "):
        if sep in t:
            a, tr = t.split(sep, 1)
            if a.strip() and tr.strip():
                return a.strip(), tr.strip()
    a = re.sub(r"(?i)\s*-\s*topic$|vevo$|\s*official$", "", artist or "").strip()
    return clean(a), t


def http_json(path, params):
    url = f"{API}/{path}?{urllib.parse.urlencode(params)}"
    delay = 1.5
    for _ in range(5):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=10) as r:
                return json.load(r)
        except urllib.error.HTTPError as e:
            if e.code == 404:
                return None
            if e.code not in (429, 500, 502, 503, 504):
                raise
        except (urllib.error.URLError, TimeoutError, OSError):
            pass
        time.sleep(delay)
        delay *= 2
    raise RuntimeError("LRCLIB tidak merespons")


def parse_lrc(lrc):
    lines = []
    for raw in (lrc or "").splitlines():
        stamps = re.findall(r"\[(\d+):(\d+(?:\.\d+)?)\]", raw)
        if not stamps:
            continue
        text = re.sub(r"\[[^\]]*\]", "", raw).strip()
        for m, s in stamps:
            lines.append([round(int(m) * 60 + float(s), 2), text])
    lines.sort(key=lambda x: x[0])
    return lines


def pick(cands, duration):
    synced = [c for c in cands if c and c.get("syncedLyrics")]
    pool = synced or [c for c in cands if c and (c.get("plainLyrics") or c.get("instrumental"))]
    if not pool:
        return None
    if duration > 0:
        return min(pool, key=lambda c: abs((c.get("duration") or 0) - duration))
    return pool[0]


def lookup(artist, title, album, duration):
    a, t = split_artist_title(artist, title)
    tried = []

    if a and t and duration > 0:
        p = {"artist_name": a, "track_name": t, "duration": int(round(duration))}
        if album:
            p["album_name"] = album
        r = http_json("get", p)
        if r and (r.get("syncedLyrics") or r.get("instrumental")):
            return r
        tried.append(r)

    queries = []
    if a and t:
        queries.append({"track_name": t, "artist_name": a})
        queries.append({"q": f"{a} {t}"})
    queries.append({"q": t})
    for q in queries:
        res = http_json("search", q) or []
        best = pick(res, duration)
        if best and best.get("syncedLyrics"):
            return best
        tried.append(best)
    return pick(tried, duration)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--artist", default="")
    ap.add_argument("--title", default="")
    ap.add_argument("--album", default="")
    ap.add_argument("--duration", type=float, default=0)
    args = ap.parse_args()

    os.makedirs(CACHE, exist_ok=True)
    key = hashlib.sha1(f"{args.artist}\n{args.title}\n{int(args.duration)}".encode()).hexdigest()
    path = os.path.join(CACHE, key + ".json")

    if os.path.exists(path):
        with open(path) as f:
            cached = json.load(f)
        fresh = cached["status"] == "ok" or time.time() - os.path.getmtime(path) < NOTFOUND_TTL
        if fresh:
            print(json.dumps(cached, ensure_ascii=False))
            return

    try:
        r = lookup(args.artist, args.title, args.album, args.duration)
    except Exception as e:
        print(json.dumps({"status": "error", "message": str(e)}))
        return

    if not r:
        out = {"status": "notfound"}
    else:
        out = {
            "status": "ok",
            "match": f"{r.get('artistName', '')} - {r.get('trackName', '')}",
            "instrumental": bool(r.get("instrumental")),
            "lines": parse_lrc(r.get("syncedLyrics")),
            "plain": [l for l in (r.get("plainLyrics") or "").splitlines() if l.strip()],
        }
        if not out["lines"] and not out["plain"] and not out["instrumental"]:
            out = {"status": "notfound"}

    with open(path, "w") as f:
        json.dump(out, f, ensure_ascii=False)
    print(json.dumps(out, ensure_ascii=False))


if __name__ == "__main__":
    main()
