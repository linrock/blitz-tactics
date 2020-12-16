const PnpWebpackPlugin = require('pnp-webpack-plugin')
const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')
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
      options: PnpWebpackPlugin.tsLoaderOptions({
        appendTsSuffixTo: [/\.vue$/]
      }),
    }
  ]
})

environment.loaders.append('pug', {
  test: /\.pug$/,
  loader: 'pug-plain-loader'
})

environment.loaders.append('chess.js', {
  test: /chess\.js/,
  parser: {
    amd: false,
  }
})

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('vue', vue)
module.exports = environment
