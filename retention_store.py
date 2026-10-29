"""Local SQLite retention case log. Cases are tied to dataset fingerprint."""
from __future__ import annotations
import sqlite3
from contextlib import contextmanager
from pathlib import Path
from datetime import datetime


class CaseStore:
    def __init__(self, path: Path):
        path.parent.mkdir(parents=True, exist_ok=True)
        self.path = path
        with self._connect() as db:
            db.execute('''CREATE TABLE IF NOT EXISTS cases (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                dataset_key TEXT NOT NULL,
                customer_id TEXT NOT NULL,
                action TEXT NOT NULL,
                note TEXT NOT NULL,
                status TEXT NOT NULL DEFAULT 'Open',
                created TEXT NOT NULL,
                updated TEXT NOT NULL
            )''')

    @contextmanager
    def _connect(self):
        db = sqlite3.connect(self.path)
        try:
            yield db
            db.commit()
        except Exception:
            db.rollback()
            raise
        finally:
            db.close()

    def create(self, key: str, customer_id: str, action: str, note: str):
        now = datetime.now().strftime('%Y-%m-%d %H:%M')
        with self._connect() as db:
            db.execute('INSERT INTO cases(dataset_key,customer_id,action,note,status,created,updated) VALUES(?,?,?,?,?,?,?)', (key,customer_id,action,note,'Open',now,now))

    def change_status(self, key: str, case_id: int, status: str):
        if status not in {'Open','Contacted','Resolved','Closed'}:
            raise ValueError('Invalid case status')
        with self._connect() as db:
            db.execute('UPDATE cases SET status=?,updated=? WHERE dataset_key=? AND id=?', (status,datetime.now().strftime('%Y-%m-%d %H:%M'),key,case_id))

    def list(self, key: str):
        with self._connect() as db:
            db.row_factory = sqlite3.Row
            rows = db.execute('SELECT id,customer_id,action,note,status,created,updated FROM cases WHERE dataset_key=? ORDER BY id DESC LIMIT 150', (key,)).fetchall()
        return [{'id': r['id'], 'customerId': r['customer_id'], 'action': r['action'], 'note': r['note'], 'status': r['status'], 'created': r['created'], 'updated': r['updated']} for r in rows]
