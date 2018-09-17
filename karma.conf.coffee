getKarmaConfig = require('resin-config-karma')
packageJSON = require('./package.json')

getKarmaConfig.DEFAULT_WEBPACK_CONFIG.externals = fs: true

module.exports = (config) ->
	karmaConfig = getKarmaConfig(packageJSON)
	config.set(karmaConfig)
