import sqlite3
import os

db_path = os.path.join(os.path.dirname(__file__), "..", "..", "INFO", "aronium-database-2026-08-02-12-00.db")

if not os.path.exists(db_path):
    print(f"Fichier introuvable : {db_path}")
    exit(1)

con = sqlite3.connect(db_path)
cur = con.cursor()

tables = [r[0] for r in cur.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()]
print(f"Nombre total de tables Aronium : {len(tables)}")

for t in ["Product", "Customer", "Document", "DocumentItem", "User"]:
    if t in tables:
        count = cur.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
        print(f" - Table {t} : {count} enregistrements")

con.close()
