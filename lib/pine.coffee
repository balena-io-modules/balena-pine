###
Copyright 2016 Resin.io

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###

###*
# @module pine
###

assign = require('lodash/assign')
defaults = require('lodash/defaults')
isEmpty = require('lodash/isEmpty')
utils = {
	isString: require('lodash/isString')
	isNumber: require('lodash/isNumber')
	isBoolean: require('lodash/isBoolean')
	isObject: require('lodash/isObject')
	isArray: require('lodash/isArray')
	isDate: require('lodash/isDate')
}
url = require('url')
Promise = require('bluebird')
PinejsClientCore = require('pinejs-client/core')(utils, Promise)
errors = require('resin-errors')
getRequest = require('resin-request')
getToken = require('resin-token')

getPine = ({ apiUrl, apiVersion, apiKey, dataDirectory } = {}) ->
	token = getToken({ dataDirectory })
	request = getRequest({ dataDirectory })
	apiPrefix = url.resolve(apiUrl, "/#{apiVersion}/")

	###*
	# @class
	# @classdesc A PineJS Client subclass to communicate with Resin.io.
	# @private
	#
	# @description
	# This subclass makes use of the [resin-request](https://github.com/resin-io-modules/resin-request) project.
	###
	class ResinPine extends PinejsClientCore

		###*
		# @summary Perform a network request to Resin.io.
		# @method
		# @private
		#
		# @param {Object} options - request options
		# @returns {Promise<*>} response body
		#
		# @todo Implement caching support.
		###
		_request: (options) ->
			defaults options,
				apiKey: apiKey
				baseUrl: apiUrl

			token.has().then (hasToken) ->
				if not hasToken and isEmpty(apiKey)
					throw new errors.ResinNotLoggedIn()
				return request.send(options).get('body')

	pineInstance = new ResinPine
		apiPrefix: apiPrefix

	assign pineInstance,
		API_URL: apiUrl
		API_VERSION: apiVersion
		API_PREFIX: apiPrefix

module.exports = getPine
