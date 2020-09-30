const PnpWebpackPlugin = require('pnp-webpack-plugin')
const { environment } = require('@rails/webpacker')
const path = require('path');

environment.config.resolve.alias = {
  'jquery': 'backbone.native',
  '@blitz': path.resolve(__dirname, '../../app/javascript'),
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
