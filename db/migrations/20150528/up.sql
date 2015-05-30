CREATE TABLE IF NOT EXISTS commands (
  command_id SERIAL UNIQUE,
  command VARCHAR UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS eggs (
  egg_id SERIAL UNIQUE,
  name VARCHAR NOT NULL,
  description VARCHAR
);

CREATE TABLE IF NOT EXISTS eggs_commands (
  egg_id INTEGER REFERENCES eggs(egg_id),
  command_id INTEGER REFERENCES commands(command_id)
);

CREATE INDEX command_search ON commands USING GIN(to_tsvector('english', command));
CREATE INDEX egg_search ON eggs USING GIN(to_tsvector('english', name || '' || description));
