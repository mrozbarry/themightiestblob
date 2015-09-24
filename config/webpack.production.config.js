var Webpack = require('webpack');
var path = require('path')

var mainPath = path.resolve(__dirname, '..', 'assets', 'scripts', 'index.coffee')
var webpackPaths = require('./webpack.paths.js')

module.exports = {
  devtool: 'source-map',

  entry: [
    mainPath
  ],

  output: webpackPaths,

  module: {
    loaders: [
      { test: /\.sass$/, loader: "style-loader!css-loader!sass?indentedSyntax" },
      { test: /\.scss$/, loader: "style-loader!css-loader!sass" },
      { test: /\.coffee$/, loader: "coffee-loader" },
      { test: /\.json$/, loader: "json-loader"},
      { test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/, loader: "url-loader?limit=10000&minetype=application/font-woff" },
      { test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/, loader: "file-loader" }
    ]
  },

  resolve: {
    extensions: ["", ".js", ".coffee", ".sass"]
  },

  plugins: [
    new Webpack.ProvidePlugin({
      "_": "lodash",
      "React": "react/addons",
      "RouterMini": "react-mini-router",
      "Flux": "flux",

      "Dispatcher": path.resolve(__dirname, '..', 'lib', 'local_modules', 'dispatcher.coffee'),
      "Component": path.resolve(__dirname, '..', 'lib', 'local_modules', 'react-component.coffee'),

      "MathExt": path.resolve(__dirname, '..', 'lib', 'local_modules', 'math_ext.coffee')
    })
  ]
};
