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
