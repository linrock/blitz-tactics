const { environment } = require('@rails/webpacker')
const typescript =  require('./loaders/typescript')

environment.config.resolve = {
  alias: {
    jquery: 'backbone.native'
  }
}

environment.loaders.append('typescript', typescript)
module.exports = environment
