CREATE MATERIALIZED VIEW unique_words AS
  SELECT word FROM ts_stat(
    $$SELECT to_tsvector('simple', name || '' || description) FROM eggs$$
  );

CREATE INDEX unique_words_idx ON unique_words USING gin(word gin_trgm_ops);
