m = require('mochainon')
Promise = require('bluebird')
url = require('url')
nock = require('nock')
settings = require('resin-settings-client')
token = require('resin-token')
tokens = require('./fixtures/tokens.json')
pine = require('../lib/pine')

describe 'Pine:', ->

	describe '.apiPrefix', ->

		it 'should equal /ewa/', ->
			m.chai.expect(pine.apiPrefix).to.equal('/ewa/')

	# The intention of this spec is to quickly double check
	# the internal _request() method works as expected.
	# The nitty grits of request are tested in resin-request.

	describe 'given a /whoami endpoint', ->

		beforeEach ->
			nock(settings.get('remoteUrl')).get('/whoami').reply(200, tokens.johndoe.token)

		afterEach ->
			nock.cleanAll()

		describe '._request()', ->

			describe 'given there is not a token', ->

				beforeEach (done) ->
					token.remove().nodeify(done)

				describe 'given a simple GET endpoint', ->

					beforeEach ->
						nock(settings.get('remoteUrl')).get('/foo').reply(200, hello: 'world')

					afterEach ->
						nock.cleanAll()

					it 'should be rejected with an authentication error message', ->
						promise = pine._request
							method: 'GET'
							url: '/foo'
						m.chai.expect(promise).to.be.rejectedWith('You have to log in')

			describe 'given there is a token', ->

				beforeEach (done) ->
					token.set(tokens.johndoe.token).nodeify(done)

				describe 'given a simple GET endpoint', ->

					beforeEach ->
						nock(settings.get('remoteUrl')).get('/foo').reply(200, hello: 'world')

					afterEach ->
						nock.cleanAll()

					it 'should eventually become the response body', ->
						promise = pine._request
							method: 'GET'
							url: '/foo'
						m.chai.expect(promise).to.eventually.become(hello: 'world')

				describe 'given a POST endpoint that mirrors the request body', ->

					beforeEach ->
						nock(settings.get('remoteUrl')).post('/foo').reply 200, (uri, body) ->
							return body

					afterEach ->
						nock.cleanAll()

					it 'should eventually become the body', ->
						promise = pine._request
							method: 'POST'
							url: '/foo'
							body:
								foo: 'bar'
						m.chai.expect(promise).to.eventually.become(foo: 'bar')

				describe '.get()', ->

					describe 'given a working pine endpoint', ->

						beforeEach ->
							@applications =
								d: [
									{ id: 1, app_name: 'Bar' }
									{ id: 2, app_name: 'Foo' }
								]

							nock(settings.get('remoteUrl'))
								.get('/ewa/application?$orderby=app_name%20asc')
								.reply(200, @applications)

						afterEach ->
							nock.cleanAll()

						it 'should make the correct request', ->
							promise = pine.get
								resource: 'application'
								options:
									orderby: 'app_name asc'
							m.chai.expect(promise).to.eventually.become(@applications.d)

					describe 'given an endpoint that returns an error', ->

						beforeEach ->
							nock(settings.get('remoteUrl'))
								.get('/ewa/application')
								.reply(500, 'Internal Server Error')

						afterEach ->
							nock.cleanAll()

						it 'should reject the promise with an error message', ->
							promise = pine.get
								resource: 'application'

							m.chai.expect(promise).to.be.rejectedWith('Internal Server Error')

				describe '.post()', ->

					describe 'given a working pine endpoint that gives back the request body', ->

						beforeEach ->
							nock(settings.get('remoteUrl'))
								.post('/ewa/application')
								.reply 201, (uri, body) ->
									return body

						afterEach ->
							nock.cleanAll()

						it 'should get back the body', ->
							promise = pine.post
								resource: 'application'
								body:
									app_name: 'App1'
									device_type: 'raspberry-pi'

							m.chai.expect(promise).to.eventually.become
								app_name: 'App1'
								device_type: 'raspberry-pi'

					describe 'given pine endpoint that returns an error', ->

						beforeEach ->
							nock(settings.get('remoteUrl'))
								.post('/ewa/application')
								.reply(404, 'Unsupported device type')

						afterEach ->
							nock.cleanAll()

						it 'should reject the promise with an error message', ->
							promise = pine.post
								resource: 'application'
								body:
									app_name: 'App1'

							m.chai.expect(promise).to.be.rejectedWith('Unsupported device type')
