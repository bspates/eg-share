module.exports = (req, res, next) ->
  req.db.client.query 
    name: 'share_egg'
    text: "INSERT 
           FROM eggs e 
           WHERE to_tsvector('english', name || '' || description) @@ plainto_tsquery($1);"
    values: [req.body.query]
  , (err, result) ->
    return if res.handleError(err)