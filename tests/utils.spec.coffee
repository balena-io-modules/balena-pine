chai = require('chai')
expect = chai.expect
utils = require('../lib/utils')

describe 'Utils:', ->

	describe '.isSuccessfulResponse()', ->

		describe 'if status code is below 200', ->

			beforeEach ->
				@response = statusCode: 199

			it 'should return false', ->
				expect(utils.isSuccessfulResponse(@response)).to.be.false

		describe 'if status code is equal to 200', ->

			beforeEach ->
				@response = statusCode: 200

			it 'should return true', ->
				expect(utils.isSuccessfulResponse(@response)).to.be.true

		describe 'if status code is within 200-299', ->

			beforeEach ->
				@response = statusCode: 250

			it 'should return true', ->
				expect(utils.isSuccessfulResponse(@response)).to.be.true

		describe 'if status code is equal to 300', ->

			beforeEach ->
				@response = statusCode: 300

			it 'should return false', ->
				expect(utils.isSuccessfulResponse(@response)).to.be.false

		describe 'if status code is above 300', ->

			beforeEach ->
				@response = statusCode: 301

			it 'should return false', ->
				expect(utils.isSuccessfulResponse(@response)).to.be.false
