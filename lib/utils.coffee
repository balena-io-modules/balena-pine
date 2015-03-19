exports.isSuccessfulResponse = (response) ->
	return 200 <= response.statusCode < 300
