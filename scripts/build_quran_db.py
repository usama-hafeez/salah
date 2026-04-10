#!/usr/bin/env python3
"""
build_quran_db.py
─────────────────
Downloads Quran text + translations from alquran.cloud (free, no API key)
and builds assets/db/quran.db with the schema expected by QuranService.

Requirements:
    pip install requests

Usage:
    python scripts/build_quran_db.py

The script creates (or overwrites) assets/db/quran.db.
Run it once from the project root before `flutter run`.
"""

import os
import sqlite3
import json
import time
import urllib.request
import urllib.error
from pathlib import Path

# ── Config ────────────────────────────────────────────────────────────────────

OUTPUT_PATH = Path(__file__).parent.parent / "assets" / "db" / "quran.db"
API_BASE = "https://api.alquran.cloud/v1"

# Editions to download
ARABIC_EDITION  = "quran-uthmani"       # Arabic (Uthmani script)
ENGLISH_EDITION = "en.sahih"             # Saheeh International (open licence)
URDU_EDITION    = "ur.jalandhry"         # Fateh Muhammad Jalandhry (open licence)

# ── Surah metadata ────────────────────────────────────────────────────────────

SURAHS_META = [
    (1,"الفاتحة","Al-Fatiha","الفاتحة","Meccan",7),
    (2,"البقرة","Al-Baqarah","البقرة","Medinan",286),
    (3,"آل عمران","Ali 'Imran","آل عمران","Medinan",200),
    (4,"النساء","An-Nisa","النساء","Medinan",176),
    (5,"المائدة","Al-Ma'idah","المائدة","Medinan",120),
    (6,"الأنعام","Al-An'am","الأنعام","Meccan",165),
    (7,"الأعراف","Al-A'raf","الأعراف","Meccan",206),
    (8,"الأنفال","Al-Anfal","الأنفال","Medinan",75),
    (9,"التوبة","At-Tawbah","التوبة","Medinan",129),
    (10,"يونس","Yunus","يونس","Meccan",109),
    (11,"هود","Hud","هود","Meccan",123),
    (12,"يوسف","Yusuf","يوسف","Meccan",111),
    (13,"الرعد","Ar-Ra'd","الرعد","Medinan",43),
    (14,"إبراهيم","Ibrahim","إبراهيم","Meccan",52),
    (15,"الحجر","Al-Hijr","الحجر","Meccan",99),
    (16,"النحل","An-Nahl","النحل","Meccan",128),
    (17,"الإسراء","Al-Isra","الإسراء","Meccan",111),
    (18,"الكهف","Al-Kahf","الكهف","Meccan",110),
    (19,"مريم","Maryam","مريم","Meccan",98),
    (20,"طه","Ta-Ha","طه","Meccan",135),
    (21,"الأنبياء","Al-Anbya","الأنبياء","Meccan",112),
    (22,"الحج","Al-Hajj","الحج","Medinan",78),
    (23,"المؤمنون","Al-Mu'minun","المؤمنون","Meccan",118),
    (24,"النور","An-Nur","النور","Medinan",64),
    (25,"الفرقان","Al-Furqan","الفرقان","Meccan",77),
    (26,"الشعراء","Ash-Shu'ara","الشعراء","Meccan",227),
    (27,"النمل","An-Naml","النمل","Meccan",93),
    (28,"القصص","Al-Qasas","القصص","Meccan",88),
    (29,"العنكبوت","Al-'Ankabut","العنكبوت","Meccan",69),
    (30,"الروم","Ar-Rum","الروم","Meccan",60),
    (31,"لقمان","Luqman","لقمان","Meccan",34),
    (32,"السجدة","As-Sajdah","السجدة","Meccan",30),
    (33,"الأحزاب","Al-Ahzab","الأحزاب","Medinan",73),
    (34,"سبأ","Saba","سبأ","Meccan",54),
    (35,"فاطر","Fatir","فاطر","Meccan",45),
    (36,"يس","Ya-Sin","يس","Meccan",83),
    (37,"الصافات","As-Saffat","الصافات","Meccan",182),
    (38,"ص","Sad","ص","Meccan",88),
    (39,"الزمر","Az-Zumar","الزمر","Meccan",75),
    (40,"غافر","Ghafir","غافر","Meccan",85),
    (41,"فصلت","Fussilat","فصلت","Meccan",54),
    (42,"الشورى","Ash-Shuraa","الشورى","Meccan",53),
    (43,"الزخرف","Az-Zukhruf","الزخرف","Meccan",89),
    (44,"الدخان","Ad-Dukhan","الدخان","Meccan",59),
    (45,"الجاثية","Al-Jathiyah","الجاثية","Meccan",37),
    (46,"الأحقاف","Al-Ahqaf","الأحقاف","Meccan",35),
    (47,"محمد","Muhammad","محمد","Medinan",38),
    (48,"الفتح","Al-Fath","الفتح","Medinan",29),
    (49,"الحجرات","Al-Hujurat","الحجرات","Medinan",18),
    (50,"ق","Qaf","ق","Meccan",45),
    (51,"الذاريات","Adh-Dhariyat","الذاريات","Meccan",60),
    (52,"الطور","At-Tur","الطور","Meccan",49),
    (53,"النجم","An-Najm","النجم","Meccan",62),
    (54,"القمر","Al-Qamar","القمر","Meccan",55),
    (55,"الرحمن","Ar-Rahman","الرحمن","Medinan",78),
    (56,"الواقعة","Al-Waqi'ah","الواقعة","Meccan",96),
    (57,"الحديد","Al-Hadid","الحديد","Medinan",29),
    (58,"المجادلة","Al-Mujadila","المجادلة","Medinan",22),
    (59,"الحشر","Al-Hashr","الحشر","Medinan",24),
    (60,"الممتحنة","Al-Mumtahanah","الممتحنة","Medinan",13),
    (61,"الصف","As-Saf","الصف","Medinan",14),
    (62,"الجمعة","Al-Jumu'ah","الجمعة","Medinan",11),
    (63,"المنافقون","Al-Munafiqun","المنافقون","Medinan",11),
    (64,"التغابن","At-Taghabun","التغابن","Medinan",18),
    (65,"الطلاق","At-Talaq","الطلاق","Medinan",12),
    (66,"التحريم","At-Tahrim","التحريم","Medinan",12),
    (67,"الملك","Al-Mulk","الملك","Meccan",30),
    (68,"القلم","Al-Qalam","القلم","Meccan",52),
    (69,"الحاقة","Al-Haqqah","الحاقة","Meccan",52),
    (70,"المعارج","Al-Ma'arij","المعارج","Meccan",44),
    (71,"نوح","Nuh","نوح","Meccan",28),
    (72,"الجن","Al-Jinn","الجن","Meccan",28),
    (73,"المزمل","Al-Muzzammil","المزمل","Meccan",20),
    (74,"المدثر","Al-Muddaththir","المدثر","Meccan",56),
    (75,"القيامة","Al-Qiyamah","القيامة","Meccan",40),
    (76,"الإنسان","Al-Insan","الإنسان","Medinan",31),
    (77,"المرسلات","Al-Mursalat","المرسلات","Meccan",50),
    (78,"النبأ","An-Naba","النبأ","Meccan",40),
    (79,"النازعات","An-Nazi'at","النازعات","Meccan",46),
    (80,"عبس","Abasa","عبس","Meccan",42),
    (81,"التكوير","At-Takwir","التكوير","Meccan",29),
    (82,"الانفطار","Al-Infitar","الانفطار","Meccan",19),
    (83,"المطففين","Al-Mutaffifin","المطففين","Meccan",36),
    (84,"الانشقاق","Al-Inshiqaq","الانشقاق","Meccan",25),
    (85,"البروج","Al-Buruj","البروج","Meccan",22),
    (86,"الطارق","At-Tariq","الطارق","Meccan",17),
    (87,"الأعلى","Al-A'la","الأعلى","Meccan",19),
    (88,"الغاشية","Al-Ghashiyah","الغاشية","Meccan",26),
    (89,"الفجر","Al-Fajr","الفجر","Meccan",30),
    (90,"البلد","Al-Balad","البلد","Meccan",20),
    (91,"الشمس","Ash-Shams","الشمس","Meccan",15),
    (92,"الليل","Al-Layl","الليل","Meccan",21),
    (93,"الضحى","Ad-Duhaa","الضحى","Meccan",11),
    (94,"الشرح","Ash-Sharh","الشرح","Meccan",8),
    (95,"التين","At-Tin","التين","Meccan",8),
    (96,"العلق","Al-'Alaq","العلق","Meccan",19),
    (97,"القدر","Al-Qadr","القدر","Meccan",5),
    (98,"البينة","Al-Bayyinah","البينة","Medinan",8),
    (99,"الزلزلة","Az-Zalzalah","الزلزلة","Medinan",8),
    (100,"العاديات","Al-'Adiyat","العاديات","Meccan",11),
    (101,"القارعة","Al-Qari'ah","القارعة","Meccan",11),
    (102,"التكاثر","At-Takathur","التكاثر","Meccan",8),
    (103,"العصر","Al-'Asr","العصر","Meccan",3),
    (104,"الهمزة","Al-Humazah","الهمزة","Meccan",9),
    (105,"الفيل","Al-Fil","الفيل","Meccan",5),
    (106,"قريش","Quraysh","قريش","Meccan",4),
    (107,"الماعون","Al-Ma'un","الماعون","Meccan",7),
    (108,"الكوثر","Al-Kawthar","الكوثر","Meccan",3),
    (109,"الكافرون","Al-Kafirun","الكافرون","Meccan",6),
    (110,"النصر","An-Nasr","النصر","Medinan",3),
    (111,"المسد","Al-Masad","المسد","Meccan",5),
    (112,"الإخلاص","Al-Ikhlas","الإخلاص","Meccan",4),
    (113,"الفلق","Al-Falaq","الفلق","Meccan",5),
    (114,"الناس","An-Nas","الناس","Meccan",6),
]

# ── Helpers ───────────────────────────────────────────────────────────────────

def fetch_json(url: str, retries: int = 3, delay: float = 2.0) -> dict:
    """Download JSON from url with retry logic."""
    for attempt in range(retries):
        try:
            print(f"  GET {url}")
            req = urllib.request.Request(url, headers={"User-Agent": "QuranDBBuilder/1.0"})
            with urllib.request.urlopen(req, timeout=30) as resp:
                return json.loads(resp.read().decode())
        except Exception as exc:
            if attempt < retries - 1:
                print(f"  Retry {attempt + 1}/{retries - 1} after error: {exc}")
                time.sleep(delay)
            else:
                raise


def build_db(arabic_data: dict, english_data: dict, urdu_data: dict) -> None:
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

    if OUTPUT_PATH.exists():
        OUTPUT_PATH.unlink()

    conn = sqlite3.connect(OUTPUT_PATH)
    cur = conn.cursor()

    # ── Schema ────────────────────────────────────────────────────────────────
    cur.executescript("""
        CREATE TABLE surahs (
            id           INTEGER PRIMARY KEY,
            name_arabic  TEXT NOT NULL,
            name_english TEXT NOT NULL,
            name_urdu    TEXT,
            revelation   TEXT,
            ayah_count   INTEGER NOT NULL
        );

        CREATE TABLE ayahs (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            surah_id     INTEGER NOT NULL,
            ayah_number  INTEGER NOT NULL,
            text_arabic  TEXT NOT NULL,
            text_english TEXT,
            text_urdu    TEXT,
            juz          INTEGER,
            UNIQUE(surah_id, ayah_number)
        );

        CREATE TABLE daily_verses (
            day_of_year  INTEGER PRIMARY KEY,
            surah_id     INTEGER NOT NULL,
            ayah_number  INTEGER NOT NULL
        );

        CREATE INDEX idx_ayahs_surah ON ayahs (surah_id);
    """)

    # ── Surahs ────────────────────────────────────────────────────────────────
    cur.executemany(
        "INSERT INTO surahs VALUES (?,?,?,?,?,?)",
        [(s[0], s[1], s[2], s[3], s[4], s[5]) for s in SURAHS_META],
    )
    print(f"  ✓ Inserted {len(SURAHS_META)} surahs")

    # ── Ayahs ─────────────────────────────────────────────────────────────────
    ar_surahs = arabic_data["data"]["surahs"]
    en_surahs = english_data["data"]["surahs"]
    ur_surahs = urdu_data["data"]["surahs"]

    # Build lookup maps  {surah_id: {ayah_number: text}}
    en_map: dict[int, dict[int, str]] = {}
    for s in en_surahs:
        en_map[s["number"]] = {a["numberInSurah"]: a["text"] for a in s["ayahs"]}

    ur_map: dict[int, dict[int, str]] = {}
    for s in ur_surahs:
        ur_map[s["number"]] = {a["numberInSurah"]: a["text"] for a in s["ayahs"]}

    rows = []
    for s in ar_surahs:
        sid = s["number"]
        for a in s["ayahs"]:
            num = a["numberInSurah"]
            juz = a.get("juz")
            rows.append((
                sid, num,
                a["text"],
                en_map.get(sid, {}).get(num),
                ur_map.get(sid, {}).get(num),
                juz,
            ))

    cur.executemany(
        "INSERT INTO ayahs (surah_id, ayah_number, text_arabic, text_english, text_urdu, juz) "
        "VALUES (?,?,?,?,?,?)",
        rows,
    )
    print(f"  ✓ Inserted {len(rows)} ayahs")

    # ── Daily verses (365 days cycling through the Quran) ────────────────────
    # Distribute 6236 verses across 365 days (one per day, cycling every ~17 years)
    verse_ids = [(s["number"], a["numberInSurah"]) for s in ar_surahs for a in s["ayahs"]]
    daily = []
    for day in range(1, 366):
        idx = (day - 1) % len(verse_ids)
        sid, anum = verse_ids[idx]
        daily.append((day, sid, anum))

    cur.executemany("INSERT INTO daily_verses VALUES (?,?,?)", daily)
    print(f"  ✓ Inserted {len(daily)} daily verse entries")

    conn.commit()
    conn.close()
    size_kb = OUTPUT_PATH.stat().st_size // 1024
    print(f"\n  ✓ Database written to {OUTPUT_PATH}  ({size_kb} KB)")


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    print("=" * 60)
    print("  Quran DB Builder")
    print("=" * 60)

    print("\n[1/3] Downloading Arabic text…")
    arabic = fetch_json(f"{API_BASE}/quran/{ARABIC_EDITION}")
    if arabic.get("code") != 200:
        raise RuntimeError(f"Arabic download failed: {arabic}")

    print("\n[2/3] Downloading English translation…")
    english = fetch_json(f"{API_BASE}/quran/{ENGLISH_EDITION}")
    if english.get("code") != 200:
        raise RuntimeError(f"English download failed: {english}")

    print("\n[3/3] Downloading Urdu translation…")
    urdu = fetch_json(f"{API_BASE}/quran/{URDU_EDITION}")
    if urdu.get("code") != 200:
        raise RuntimeError(f"Urdu download failed: {urdu}")

    print("\nBuilding SQLite database…")
    build_db(arabic, english, urdu)

    print("\n" + "=" * 60)
    print("  Done! Run `flutter run` to use the Quran reader.")
    print("=" * 60)


if __name__ == "__main__":
    main()
