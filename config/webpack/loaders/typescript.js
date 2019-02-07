module.exports = {
  test: /\.(ts|tsx)?(\.erb)?$/,
  use: [
    {
      loader: 'babel-loader',
    }
  ]
}
