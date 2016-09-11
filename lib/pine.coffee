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

_ = require('lodash')
url = require('url')
Promise = require('bluebird')
PinejsClientCore = require('pinejs-client/core')(_, Promise)
request = require('resin-request')
settings = require('resin-settings-client')
token = require('resin-token')
errors = require('resin-errors')

API_VERSION = 'v1'

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
		token.has().then (hasToken) ->
			if not hasToken and _.isEmpty(process.env.RESIN_API_KEY)
				throw new errors.ResinNotLoggedIn()
			return request.send(options).get('body')

module.exports = new ResinPine
	apiPrefix: url.resolve(settings.get('apiUrl'), "/#{API_VERSION}/")

module.exports.API_VERSION = API_VERSION
