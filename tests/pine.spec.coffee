_ = require('lodash')
m = require('mochainon')
url = require('url')
tokens = require('./fixtures/tokens.json')
getPine = require('../lib/pine')
ResinAuth = require('resin-auth')['default']
getRequest = require('resin-request')

{ fetchMock, mockedFetch } = require('resin-fetch-mock')

IS_BROWSER = window?

dataDirectory = null
apiUrl = 'https://api.resin.io'
if not IS_BROWSER
	temp = require('temp').track()
	dataDirectory = temp.mkdirSync()

auth = new ResinAuth({ dataDirectory })

request = getRequest({ auth })
request._setFetch(mockedFetch)

apiVersion = 'v2'

buildPineInstance = (extraOpts) ->
	getPine _.assign {
		apiUrl, apiVersion, request, auth
		apiKey: null
	}, extraOpts

describe 'Pine:', ->

	describe '.apiPrefix', ->

		it "should equal /#{apiVersion}/", ->
			pine = buildPineInstance()
			m.chai.expect(pine.apiPrefix).to.equal(pine.API_PREFIX)

	# The intention of this spec is to quickly double check
	# the internal _request() method works as expected.
	# The nitty grits of request are tested in resin-request.

	describe 'given a /whoami endpoint', ->

		beforeEach ->
			@pine = buildPineInstance()
			fetchMock.get("#{@pine.API_URL}/whoami", tokens.johndoe.token)

		afterEach ->
			fetchMock.restore()

		describe '._request()', ->

			describe 'given there is no auth', ->

				beforeEach ->
					auth.removeKey()

				describe 'given a simple GET endpoint', ->

					beforeEach ->
						@pine = buildPineInstance()
						fetchMock.get "begin:#{@pine.API_URL}/foo",
							body: hello: 'world'
							headers:
								'Content-Type': 'application/json'

					afterEach ->
						fetchMock.restore()

					describe 'given there is no api key', ->
						beforeEach: ->
							@pine = buildPineInstance(apiKey: '')

						it 'should be rejected with an authentication error message', ->
							promise = @pine._request
								baseUrl: @pine.API_URL
								method: 'GET'
								url: '/foo'
							m.chai.expect(promise).to.be.rejectedWith('You have to log in')

					describe 'given there is an api key', ->
						beforeEach ->
							@pine = buildPineInstance(apiKey: '123456789')

						it 'should make the request successfully', ->
							promise = @pine._request
								baseUrl: @pine.API_URL
								method: 'GET'
								url: '/foo'
							m.chai.expect(promise).to.become(hello: 'world')

			describe 'given there is an auth', ->

				beforeEach ->
					auth.setKey(tokens.johndoe.token)

				describe 'given a simple GET endpoint', ->

					beforeEach ->
						@pine = buildPineInstance()
						fetchMock.get "#{@pine.API_URL}/foo",
							body: hello: 'world'
							headers:
								'Content-Type': 'application/json'

					afterEach ->
						fetchMock.restore()

					it 'should eventually become the response body', ->
						promise = @pine._request
							baseUrl: @pine.API_URL
							method: 'GET'
							url: '/foo'
						m.chai.expect(promise).to.eventually.become(hello: 'world')

				describe 'given a POST endpoint that mirrors the request body', ->

					beforeEach ->
						@pine = buildPineInstance()
						fetchMock.post "#{@pine.API_URL}/foo", (url, opts) ->
							status: 200
							body: opts.body
							headers:
								'Content-Type': 'application/json'

					afterEach ->
						fetchMock.restore()

					it 'should eventually become the body', ->
						promise = @pine._request
							baseUrl: @pine.API_URL
							method: 'POST'
							url: '/foo'
							body:
								foo: 'bar'
						m.chai.expect(promise).to.eventually.become(foo: 'bar')

				describe '.get()', ->

					describe 'given a working pine endpoint', ->

						beforeEach ->
							@pine = buildPineInstance()

							@applications =
								d: [
									{ id: 1, app_name: 'Bar' }
									{ id: 2, app_name: 'Foo' }
								]

							fetchMock.get "#{@pine.API_URL}/#{apiVersion}/application?$orderby=app_name asc",
								status: 200
								body: @applications
								headers:
									'Content-Type': 'application/json'

						afterEach ->
							fetchMock.restore()

						it 'should make the correct request', ->
							promise = @pine.get
								resource: 'application'
								options:
									$orderby: 'app_name asc'
							m.chai.expect(promise).to.eventually.become(@applications.d)

					describe 'given an endpoint that returns an error', ->

						beforeEach ->
							@pine = buildPineInstance()
							fetchMock.get "#{@pine.API_URL}/#{apiVersion}/application",
								status: 500
								body: 'Internal Server Error'

						afterEach ->
							fetchMock.restore()

						it 'should reject the promise with an error message', ->
							promise = @pine.get
								resource: 'application'

							m.chai.expect(promise).to.be.rejectedWith('Internal Server Error')

				describe '.post()', ->

					describe 'given a working pine endpoint that gives back the request body', ->

						beforeEach ->
							@pine = buildPineInstance()
							fetchMock.post "#{@pine.API_URL}/#{apiVersion}/application", (url, opts) ->
								status: 201
								body: opts.body
								headers:
									'Content-Type': 'application/json'

						afterEach ->
							fetchMock.restore()

						it 'should get back the body', ->
							promise = @pine.post
								resource: 'application'
								body:
									app_name: 'App1'
									device_type: 'raspberry-pi'

							m.chai.expect(promise).to.eventually.become
								app_name: 'App1'
								device_type: 'raspberry-pi'

					describe 'given pine endpoint that returns an error', ->

						beforeEach ->
							@pine = buildPineInstance()
							fetchMock.post "#{@pine.API_URL}/#{apiVersion}/application",
								status: 404
								body: 'Unsupported device type'

						afterEach ->
							fetchMock.restore()

						it 'should reject the promise with an error message', ->
							promise = @pine.post
								resource: 'application'
								body:
									app_name: 'App1'

							m.chai.expect(promise).to.be.rejectedWith('Unsupported device type')
