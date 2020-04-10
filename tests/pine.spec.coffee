_ = require('lodash')
m = require('mochainon')
url = require('url')
tokens = require('./fixtures/tokens.json')
getPine = require('../lib/pine')
BalenaAuth = require('balena-auth')['default']
getRequest = require('balena-request')

mockServer = require('mockttp').getLocal()

IS_BROWSER = window?

dataDirectory = null
if not IS_BROWSER
	temp = require('temp').track()
	dataDirectory = temp.mkdirSync()

auth = new BalenaAuth({ dataDirectory })

request = getRequest({ auth })

apiVersion = 'v2'

buildPineInstance = (apiUrl, extraOpts) ->
	getPine _.assign {
		apiUrl, apiVersion, request, auth
		apiKey: null
	}, extraOpts

describe 'Pine:', ->

	beforeEach ->
		mockServer.start()

	afterEach ->
		mockServer.stop()

	describe '.apiPrefix', ->

		it "should equal /#{apiVersion}/", ->
			pine = buildPineInstance(mockServer.url)
			m.chai.expect(pine.apiPrefix).to.equal(pine.API_PREFIX)

	# The intention of this spec is to quickly double check
	# the internal _request() method works as expected.
	# The nitty grits of request are tested in balena-request.

	describe 'given a /whoami endpoint', ->

		beforeEach ->
			@pine = buildPineInstance(mockServer.url)
			mockServer.get('/whoami').thenJSON(200, tokens.johndoe.token)
			mockServer.get('/foo')
				.withHeaders({ 'Authorization': "Bearer #{tokens.johndoe.token}" })
				.thenJSON(200, hello: 'world')
			mockServer.get('/foo').thenCallback (req) ->
				if req.url.endsWith("?apikey=#{tokens.johndoe.token}")
					return {
						status: 200,
						json: hello: 'world'
					}

				return {
					status: 401
					body: 'Unauthorized'
				}

		describe '._request()', ->

			describe 'given there is no auth', ->

				beforeEach ->
					auth.removeKey()

				describe 'given a simple GET endpoint', ->

					describe 'given a public resource', ->

						beforeEach ->
							@pine = buildPineInstance(mockServer.url)
							mockServer.get('/public_resource').thenJSON(200, hello: 'public world')

						describe 'given there is no api key', ->

							it 'should be successful', ->
								promise = @pine._request
									baseUrl: @pine.API_URL
									method: 'GET'
									url: '/public_resource'
								m.chai.expect(promise).to.become(hello: 'public world')

							it 'should be successful, if sent anonymously', ->
								promise = @pine._request
									baseUrl: @pine.API_URL
									method: 'GET'
									url: '/public_resource'
									anonymous: true
								m.chai.expect(promise).to.become(hello: 'public world')

						describe 'given there is an api key', ->

							it 'should make the request successfully', ->
								promise = @pine._request
									baseUrl: @pine.API_URL
									method: 'GET'
									url: '/public_resource'
								m.chai.expect(promise).to.become(hello: 'public world')

					describe 'given a non-public resource', ->

						describe 'given there is no api key', ->

							beforeEach ->
								@pine = buildPineInstance(mockServer.url, apiKey: '')

							it 'should be rejected with an authentication error message', ->
								promise = @pine._request
									baseUrl: @pine.API_URL
									method: 'GET'
									url: '/foo'
								m.chai.expect(promise).to.be.rejectedWith('You have to log in')

							it 'should be rejected with an unauthorized error, if sent anonymously', ->
								promise = @pine._request
									baseUrl: @pine.API_URL
									method: 'GET'
									url: '/foo'
									anonymous: true
								m.chai.expect(promise).to.be.rejectedWith('Unauthorized')
								.then (res) ->
									m.chai.expect(res.statusCode).to.equal(401)

						describe 'given there is an api key', ->

							beforeEach ->
								@pine = buildPineInstance(mockServer.url, apiKey: tokens.johndoe.token)

							it 'should make the request successfully', ->
								promise = @pine._request
									baseUrl: @pine.API_URL
									method: 'GET'
									url: '/foo'
								m.chai.expect(promise).to.become(hello: 'world')

							it 'should make the request successfully, if sent anonymously', ->
								promise = @pine._request
									baseUrl: @pine.API_URL
									method: 'GET'
									url: '/foo'
									anonymous: true
								m.chai.expect(promise).to.become(hello: 'world')

			describe 'given there is an auth', ->

				beforeEach ->
					auth.setKey(tokens.johndoe.token)

				describe 'given a simple GET endpoint', ->

					describe 'given a public resource', ->

						beforeEach ->
							@pine = buildPineInstance(mockServer.url)
							mockServer.get('/public_resource').thenJSON(200, hello: 'public world')

						it 'should be successful', ->
							promise = @pine._request
								baseUrl: @pine.API_URL
								method: 'GET'
								url: '/public_resource'
							m.chai.expect(promise).to.become(hello: 'public world')

						it 'should be successful, if sent anonymously', ->
							promise = @pine._request
								baseUrl: @pine.API_URL
								method: 'GET'
								url: '/public_resource'
								anonymous: true
							m.chai.expect(promise).to.become(hello: 'public world')

					describe 'given a non-public resource', ->

						beforeEach ->
							@pine = buildPineInstance(mockServer.url)

						it 'should eventually become the response body', ->
							promise = @pine._request
								baseUrl: @pine.API_URL
								method: 'GET'
								url: '/foo'
							m.chai.expect(promise).to.eventually.become(hello: 'world')

						it 'should not send the auth token, if using an anonymous flag', ->
							promise = @pine._request
								baseUrl: @pine.API_URL
								method: 'GET'
								url: '/foo'
								anonymous: true
							m.chai.expect(promise).to.be.rejectedWith('Request error: Unauthorized')

				describe 'given a POST endpoint that mirrors the request body', ->

					beforeEach ->
						@pine = buildPineInstance(mockServer.url)
						mockServer.post('/foo').thenCallback (req) ->
							status: 200
							json: req.body.json

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
							@pine = buildPineInstance(mockServer.url)

							@applications =
								d: [
									{ id: 1, app_name: 'Bar' }
									{ id: 2, app_name: 'Foo' }
								]

							mockServer
							.get("/#{apiVersion}/application")
							.withQuery('$orderby': 'app_name asc')
							.thenJSON(200, @applications)

						it 'should make the correct request', ->
							promise = @pine.get
								resource: 'application'
								options:
									$orderby: 'app_name asc'
							m.chai.expect(promise).to.eventually.become(@applications.d)

					describe 'given an endpoint that returns an error', ->

						beforeEach ->
							@pine = buildPineInstance(mockServer.url)
							mockServer
							.get("/#{apiVersion}/application")
							.thenReply(500, 'Internal Server Error')

						it 'should reject the promise with an error message', ->
							promise = @pine.get
								resource: 'application'

							m.chai.expect(promise).to.be.rejectedWith('Internal Server Error')

				describe '.post()', ->

					describe 'given a working pine endpoint that gives back the request body', ->

						beforeEach ->
							@pine = buildPineInstance(mockServer.url)

							mockServer.post("/#{apiVersion}/application").thenCallback (req) ->
								status: 201
								json: req.body.json

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
							@pine = buildPineInstance(mockServer.url)
							mockServer
							.get("/#{apiVersion}/application")
							.thenReply(404, 'Unsupported device type')

						it 'should reject the promise with an error message', ->
							promise = @pine.post
								resource: 'application'
								body:
									app_name: 'App1'

							m.chai.expect(promise).to.be.rejectedWith('Unsupported device type')
