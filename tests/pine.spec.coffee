url = require('url')
nock = require('nock')
chai = require('chai')
expect = chai.expect
settings = require('resin-settings-client')
pine = require('../lib/pine')

describe 'Pine:', ->

	describe '.apiPrefix', ->

		it 'should equal /ewa/', ->
			expect(pine.apiPrefix).to.equal('/ewa/')

	describe '_request()', ->

		describe 'given the response is successful', ->

			beforeEach ->
				nock(settings.get('remoteUrl'))
					.get('/foo')
					.reply(200, 'Bar')

			it 'should return the body', (done) ->
				pine._request
					method: 'GET'
					url: '/foo'
				.then (body) ->
					expect(body).to.equal('Bar')
					done()

		describe 'given the response is not successful', ->

			beforeEach ->
				nock(settings.get('remoteUrl'))
					.get('/foo')
					.reply(400, 'Bar')

			it 'should return an error with the body', (done) ->
				pine._request
					method: 'GET'
					url: '/foo'
				.catch (error) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('Request error: Bar')
					done()

		describe 'given an endpoint that returns the body', ->

			beforeEach ->
				nock(settings.get('remoteUrl'))
					.post('/body')
					.reply 200, (uri, body) ->
						return body

			it 'should accept the body as "data"', (done) ->
				pine._request
					method: 'POST'
					url: '/body'
					data:
						hello: 'world'
				.then (body) ->
					expect(body).to.deep.equal(hello: 'world')
					done()

			it 'should accept the body as "body"', (done) ->
				pine._request
					method: 'POST'
					url: '/body'
					body:
						hello: 'world'
				.then (body) ->
					expect(body).to.deep.equal(hello: 'world')
					done()

			describe 'given both "data" and "body"', ->

				it 'should give priority to "body"', (done) ->
					pine._request
						method: 'POST'
						url: '/body'
						data:
							name: 'data'
						body:
							name: 'body'
					.then (body) ->
						expect(body).to.deep.equal(name: 'body')
						done()
