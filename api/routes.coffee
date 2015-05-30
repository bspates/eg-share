bodyParser = require 'body-parser'
search = require './engines/search'
share = require './engines/share'
db = require '../middleware/db'
convienceHandlers = require '../middleware/convienceHandlers'

module.exports = (router) ->
  # Attach middleware
  router.use bodyParser.json()
  router.use db
  router.use convienceHandlers
   
  # Define Routes
  router.route '/search'
    .post search

  router.route '/share'
    .post share

  # Return router object to attach to express app object
  return router
