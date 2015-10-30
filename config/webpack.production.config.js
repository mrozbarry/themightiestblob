var Webpack = require('webpack'),
    HtmlWebpackPlugin = require('html-webpack-plugin'),
    path = require('path'),
    mainPath = path.resolve(__dirname, '..', 'assets', 'scripts', 'index.coffee'),
    webpackPaths = require('./webpack.paths.js');

module.exports = {
  entry: [
    mainPath
  ],

  output: {
    path: webpackPaths.path,
    publicPath: webpackPaths.publicPath,
    filename: webpackPaths.filename
  },

  module: {
    loaders: [
      { test: /\.sass$/, loader: "style-loader!css-loader!sass?indentedSyntax" },
      { test: /\.scss$/, loader: "style-loader!css-loader!sass" },
      { test: /\.css$/, loader: "style-loader!css-loader" },
      { test: /\.coffee$/, loader: "coffee-loader" },
      { test: /\.json$/, loader: "json-loader"}
    ]
  },

  resolve: {
    extensions: ["", ".js", ".coffee", ".sass"]
  },

  plugins: [
    new Webpack.optimize.OccurenceOrderPlugin(),
    new HtmlWebpackPlugin(),
    new Webpack.ProvidePlugin({
      "_": "lodash",
      "ReactDOM": "react-dom",
      "React": "react",
      "Flux": "flux",

      "Dispatcher": path.resolve(__dirname, '..', 'lib', 'local_modules', 'dispatcher.coffee'),
      "Component": path.resolve(__dirname, '..', 'lib', 'local_modules', 'react-component.coffee')
    })
  ]
};
