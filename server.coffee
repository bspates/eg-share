express = require 'express'

app = express()

app.use '/api', require('./api/routes') express.Router()

app.listen process.env.PORT
console.log 'up and running'
