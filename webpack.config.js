const path = require("path");

const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const { VueLoaderPlugin } = require('vue-loader');
const webpack = require("webpack");


const mode = process.env.NODE_ENV === 'development' ? 'development' : 'production';

module.exports = {
  mode,
  devtool: "source-map",
  entry: {
    application: "./app/javascript/application.ts"
  },
  output: {
    filename: "[name].js",
    sourceMapFilename: "[file].map",
    chunkFormat: "module",
    path: path.resolve(__dirname, "app/assets/builds"),
  },
  resolve: {
    extensions: [".ts", ".tsx", ".vue", ".css", ".js"],
    alias: {
      'jquery': 'backbone.native',
      '@blitz': path.resolve(__dirname, './app/javascript'),
       vue: '@vue/runtime-dom',
    },
  },
  plugins: [
    new VueLoaderPlugin(),
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1
    }),
    new MiniCssExtractPlugin({
      filename: 'application-webpack.css',
    }),
  ],
  optimization: {
    moduleIds: 'deterministic',
  },
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: 'vue-loader',
      },
      {
        test: /\.ts$/,
        loader: 'ts-loader',
        options: { appendTsSuffixTo: [/\.vue$/] },
      },
      {
        test: /\.pug$/,
        loader: 'pug-plain-loader',
      },
      {
        test: /\.sass$/,
        use: [
           MiniCssExtractPlugin.loader, // extract CSS into separate files
          // 'style-loader', // Injects styles into the DOM
          'css-loader',   // Translates CSS into CommonJS
          'sass-loader',  // Compiles SASS to CSS
        ],
      },

      // {
      //   test: /chess\.js/,
      //   parser: {
      //     amd: false,
      //   }
      // },

      /*
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env'],
          },
        },
      },
      */
      {
        test: /\.css$/, // Rule for CSS files
        use: ['style-loader', 'css-loader'], // Use style-loader and css-loader
      },
      {
        test: /\.html$/,
        use: ['html-loader'],
      },
    ],
  },
  devServer: {
    static: path.resolve(__dirname, 'app/assets/builds'),
    hot: true,
  },
}
