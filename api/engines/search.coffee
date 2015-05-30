findEggs = (client, query, cb) ->
  client.query
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
    values: [query]
  , cb

findQuerySuggestions = (client, failedQuery, cb) ->
  subQuery = "SELECT to_tsvector('simple', '#{failedQuery}')"
  client.query 
    name: 'suggest_better_query'
    text: "
      WITH target_words AS (
        SELECT word 
        FROM ts_stat($1)
      ), matches AS (
        SELECT 
          u.word AS suggestion, 
          t.word AS original,
          ROW_NUMBER() OVER (
            PARTITION BY t.word ORDER BY t.word <-> u.word
          ) AS r
        FROM 
          unique_words u, 
          target_words t
        WHERE similarity(u.word, t.word) > 0.29
      ) SELECT * FROM matches WHERE r <= 1;
    "
    values: [subQuery]
  , cb

mapSuggestedQuery = (originalQuery, querySuggestions, cb) ->
  suggestion = originalQuery
  for word in querySuggestions
    suggestion = suggestion.replace word.original, word.suggestion

  cb null, suggestion

# Engine function
module.exports = (req, res, next) ->
  findEggs req.db.client, req.body.query, (err, result) ->
    return if res.handleError(err)

    resultStructure = 
      suggestion: ''
      eggs: []

    # If we have results exit
    if result.rows.length isnt 0
      resultStructure.eggs = result.rows
      return res.handleSuccess resultStructure
   
    # Else suggest a better query
    findQuerySuggestions req.db.client, req.body.query, (err, result) ->
      return if res.handleError(err)
      return res.handleSuccess(resultStructure) if result.rows.length is 0

      mapSuggestedQuery req.body.query, result.rows, (err, suggestion) -> 
        resultStructure.suggestion = suggestion
        res.handleSuccess resultStructure
