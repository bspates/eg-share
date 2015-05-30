bodyParser = require 'body-parser'
pg = require 'pg'

search = require './engines/search'
share = require './engines/share'

module.exports = (router) ->
  router.use bodyParser.json()

  router.use (req, res, next) ->
    pg.connect process.env.DB_CON_URL, (err, client, done) ->
      if err
        console.error 'error fetching client from pool', err
        res.sendStatus 500

      else
        req.db = {client, done}
        next()

  router.use (req, res, next) ->
    res.handleError = (err) ->
      return false unless err
      req.db.done()
      res.status = 500
      res.json
        success: false
        result: {}
        message: err
      return true

    res.handleSuccess = (result, message = '') ->
      req.db.done()
      res.json
        success: true
        result: result or  {}
        message: message 

    next()

  router.route '/search'
    .post search

  router.route '/share'
    .post share

  return router
