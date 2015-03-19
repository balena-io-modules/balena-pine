_ = require('lodash')
Promise = require('bluebird')
PinejsClientCore = require('pinejs-client/core')(_, Promise)
request = require('./request')
utils = require('./utils')

class ResinPine extends PinejsClientCore

	_request: (params) ->
		params.json = true
		params.gzip ?= true

		request(params).spread (response, body) ->
			return body if utils.isSuccessfulResponse(response)
			throw new Error(body)

module.exports = new ResinPine
	apiPrefix: '/ewa/'
