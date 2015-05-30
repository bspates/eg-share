resultStructure = 
  suggestion: ''
  eggs: []

module.exports = (req, res, next) ->
  req.db.client.query
    name: 'meta_egg_search'
    text: "
      SELECT
        name, 
        description
      FROM eggs
      WHERE 
       to_tsvector(
          'english',
          name || '' || description
        ) @@ plainto_tsquery($1)
      ORDER BY ts_rank(to_tsvector(
        'english',
        name || '' || description
      ), plainto_tsquery($1))
      DESC
      LIMIT 5;
    "
    values: [req.body.query]
  , (err, result) ->
    return if res.handleError(err)

    # If we have results exit
    if result.rows.length isnt 0
      resultStructure.eggs = result.rows
      return res.handleSuccess resultStructure

    req.db.client.query 
      name: 'meta_alt_egg_search'
      text: "
        WITH target_words AS (
          SELECT 
            word 
          FROM ts_stat(
            $$
              SELECT to_tsvector('simple', $1)
            $$
          )
        )
        SELECT 
          u.word AS suggestion, 
          t.word AS original
        FROM unique_words u, target_words t
        WHERE similarity(u.word, t.word) > 0.5
        ORDER BY u.word <-> t.word;
      "
      values: [req.body.query]
    , (err, result) ->
      return if res.handleError(err)

      suggestion = req.body.query
      for word in result 
        suggestion.replace word.original, word.suggestion

      resultStructure.suggestion = suggestion
      res.handleSuccess resultStructure



