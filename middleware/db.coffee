pg = require 'pg'

module.exports = (req, res, next) -> 
  pg.connect process.env.DB_CON_URL, (err, client, done) ->
    if err
      console.error 'error fetching client from pool', err
      res.sendStatus 500

    else
      req.db = {client, done}
      next()
