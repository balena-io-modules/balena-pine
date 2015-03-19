nock = require('nock')
chai = require('chai')
expect = chai.expect
settings = require('resin-settings-client')
request = require('../lib/request')

describe 'Request:', ->

	describe 'given a get endpoint', ->

		beforeEach ->
			nock(settings.get('remoteUrl'))
				.get('/hello')
				.reply(200, 'world')

		it 'should make the request', (done) ->
			request
				method: 'GET'
				url: '/hello'
			.spread (response, body)	->
				expect(response.statusCode).to.equal(200)
				expect(body).to.equal('world')
				done()

	describe 'given a post endpoint', ->

		beforeEach ->
			nock(settings.get('remoteUrl'))
				.post('/greeting', name: 'John Doe')
				.reply(201, 'Hello John Doe')

		it 'should make the request', (done) ->
			request
				method: 'POST'
				url: '/greeting'
				json:
					name: 'John Doe'
			.spread (response, body)	->
				expect(response.statusCode).to.equal(201)
				expect(body).to.equal('Hello John Doe')
				done()

	describe 'given a put endpoint', ->

		beforeEach ->
			nock(settings.get('remoteUrl'))
				.put('/foo', bar: 'qux')
				.reply(200, 'Foo Bar')

		it 'should make the request', (done) ->
			request
				method: 'PUT'
				url: '/foo'
				json:
					bar: 'qux'
			.spread (response, body)	->
				expect(response.statusCode).to.equal(200)
				expect(body).to.equal('Foo Bar')
				done()

	describe 'given a delete endpoint', ->

		beforeEach ->
			nock(settings.get('remoteUrl'))
				.delete('/bar', name: 'John Doe')
				.reply(200, 'John Doe deleted')

		it 'should make the request', (done) ->
			request
				method: 'DELETE'
				url: '/bar'
				json:
					name: 'John Doe'
			.spread (response, body)	->
				expect(response.statusCode).to.equal(200)
				expect(body).to.equal('John Doe deleted')
				done()
