module.exports = (req, res, next) ->
  res.handleError = (err) ->
    return false unless err
    req.db.done()
    res.status 500
    res.json
      success: false
      result: {}
      message: err.message
    res.end()
    return true

  res.handleSuccess = (result, message = '') ->
    req.db.done()
    res.json
      success: true
      result: result or  {}
      message: message 

  next()
