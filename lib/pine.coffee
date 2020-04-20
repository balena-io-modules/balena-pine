###
Copyright 2016 Balena

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

url = require('url')
Promise = require('bluebird')
{ PinejsClientCoreFactory } = require('pinejs-client-core')
PinejsClientCore = PinejsClientCoreFactory(Promise)
errors = require('balena-errors')

getPine = ({ apiUrl, apiVersion, apiKey, request, auth } = {}) ->
	apiPrefix = url.resolve(apiUrl, "/#{apiVersion}/")

	###*
	# @class
	# @classdesc A PineJS Client subclass to communicate with balena.
	# @private
	#
	# @description
	# This subclass makes use of the [balena-request](https://github.com/balena-io-modules/balena-request) project.
	###
	class BalenaPine extends PinejsClientCore

		###*
		# @summary Perform a network request to balena.
		# @method
		# @private
		#
		# @param {Object} options - request options
		# @returns {Promise<*>} response body
		#
		# @todo Implement caching support.
		###
		_request: (options) ->
			auth.hasKey().then (hasKey) ->
				authenticated = hasKey or (apiKey? and apiKey.length > 0)

				options = Object.assign({
					apiKey: apiKey
					baseUrl: apiUrl
					sendToken: authenticated && !options.anonymous
				}, options)

				request.send(options)
					.get('body')
					.catch (err) ->
						if err.statusCode != 401
							throw err

						# Always return the API error when the anonymous flag is used.
						if options.anonymous
							throw err

						# We want to allow unauthenticated users to make requests
						# to public resources, but still reject with a NotLoggedIn
						# error if the response ends up being a 401.
						if !authenticated
							throw new errors.BalenaNotLoggedIn()

						throw err

	pineInstance = new BalenaPine
		apiPrefix: apiPrefix

	Object.assign pineInstance,
		API_URL: apiUrl
		API_VERSION: apiVersion
		API_PREFIX: apiPrefix

module.exports = getPine
