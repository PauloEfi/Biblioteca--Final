PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'professor', 'aluno')),
  active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS books (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  isbn TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  authors TEXT NOT NULL,
  category TEXT NOT NULL,
  publisher TEXT NOT NULL,
  publication_year INTEGER NOT NULL CHECK (publication_year >= 0),
  total_copies INTEGER NOT NULL CHECK (total_copies >= 0),
  available_copies INTEGER NOT NULL CHECK (available_copies >= 0),
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (available_copies <= total_copies)
);

CREATE TRIGGER IF NOT EXISTS trg_books_updated_at
AFTER UPDATE ON books
FOR EACH ROW
BEGIN
  UPDATE books SET updated_at = CURRENT_TIMESTAMP WHERE id = OLD.id;
END;

CREATE TABLE IF NOT EXISTS loans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  book_id INTEGER NOT NULL,
  loan_date TEXT NOT NULL,
  due_date TEXT NOT NULL,
  returned_at TEXT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (book_id) REFERENCES books(id)
);

CREATE INDEX IF NOT EXISTS idx_loans_user_active
  ON loans (user_id, returned_at);

CREATE INDEX IF NOT EXISTS idx_loans_due_active
  ON loans (due_date, returned_at);

CREATE TABLE IF NOT EXISTS acquisition_requests (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  authors TEXT NOT NULL,
  category TEXT NOT NULL,
  publisher TEXT NULL,
  justification TEXT NULL,
  status TEXT NOT NULL DEFAULT 'pendente'
    CHECK (status IN ('pendente', 'aprovada', 'recusada')),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reviewed_at TEXT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO users (name, email, password_hash, role)
SELECT
  'Administrador Biblioteca',
  'admin@bibliotech.local',
  '32768:8:1$dNWvcsWdvLxjvv1I$97655cd2ff2899557345913ad851ab1bb60a4938b42542dae57bc90dc94825cebb4892bb8f32231083b494662432276e1cc9bdc61969f2eb23e9cd0af0250cc7',
  'admin'
WHERE NOT EXISTS (
  SELECT 1 FROM users WHERE email = 'admin@bibliotech.local'
);
UPDATE users
SET password_hash = 'scrypt:32768:8:1$tRQNRwml0lqRG3XB$f86503648c81a6ca559b742eb653b116de3b9c453771b31c1e863f6e27aac71950fda6893d92a6215f5bfd58722f5d7411bd42ab3f9db6b023c152a7641c7118'
WHERE email = 'admin@bibliotech.local';
