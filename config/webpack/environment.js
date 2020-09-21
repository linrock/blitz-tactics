const PnpWebpackPlugin = require('pnp-webpack-plugin')
const { environment } = require('@rails/webpacker')

environment.config.resolve.alias = {
  jquery: 'backbone.native'
}

environment.loaders.append('typescript', {
  test: /\.tsx?(\.erb)?$/,
  use: [
    {
      loader: 'ts-loader',
      options: PnpWebpackPlugin.tsLoaderOptions()
    }
  ]
})

module.exports = environment
