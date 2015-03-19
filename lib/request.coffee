Promise = require('bluebird')
request = require('resin-request')

module.exports = Promise.promisify(request.request, request)
