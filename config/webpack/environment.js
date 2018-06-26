const { environment } = require('@rails/webpacker')

environment.config.resolve = {
  alias: {
    jquery: 'jquery-slim'
  }
}

module.exports = environment
