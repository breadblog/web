/* eslint indent:0 */
const Config = require('webpack-chain')
const HtmlPlugin = require('html-webpack-plugin')
const ExtractCssPlugin = require('mini-css-extract-plugin')
const CleanPlugin = require('clean-webpack-plugin')
const CopyPlugin = require('copy-webpack-plugin')
const { DefinePlugin } = require('webpack')

const {
  src,
  dist,
  root,
  build,
} = require('./webpack/util')

const config = new Config()

config
  .target('web')
  .entry('main')
    .add(src('js', 'index.js'))
    .end()
  .entry('animate-css')
    .add(root('node_modules', 'animate.css', 'animate.min.css'))
    .end()
  .devtool('none')
  .resolve
    .alias
      .set('@js', src('js'))
      .set('@font', src('fonts'))
      .set('@main$', src('Main.elm'))
      .end()
    .extensions
      .add('.js')
      .add('.elm')
      .add('.css')
      .add('.svg')
      .end()
    .end()
  .module
    .rule('js')
      .test(/\.js$/)
      .exclude
        .add(/node_modules/)
        .end()
      .use('babel')
        .loader('babel-loader')
        .options({
          presets: ['@babel/env'],
        })
        .end()
      .end()
    .rule('elm')
      .test(/\.elm$/)
      .exclude
        .add(/elm-stuff/)
        .add(/node_modules/)
        .end()
      .use('elm')
        .loader('elm-webpack-loader')
        .options({
          cwd: root(),
        })
        .end()
      .end()
    .rule('css')
      .test(/\.css$/)
      .use('extract css loader')
        .loader(ExtractCssPlugin.loader)
        .end()
      .use('css loader')
        .loader('css-loader')
        .end()
      .end()
    .rule('font')
      .test(/\.ttf$/)
      .use('url loader')
        .loader('url-loader')
        .options({ limit: 50000 })
        .end()
      .end()
    .end()
  .plugin('html')
    .use(HtmlPlugin, [{
      template: src('html', 'index.html'),
      inject: 'body',
    }])
    .end()
  .plugin('copy')
    .use(CopyPlugin, [[
      {
        from: root('assets'),
        to: dist(),
      },
    ]])
    .end()
  .plugin('clean')
    .use(CleanPlugin, [
      [dist()],
      { root: root() },
    ])
    .end()
  .end()

// Development

if (build() === 'dev') {
  config
    .mode('development')
    .devServer
      .contentBase(dist())
      .port(9080)
      .historyApiFallback(true)
      .end()
    .output
      .path(dist())
      .filename('[name].js')
      .publicPath('/')
      .end()
    .module
      .rule('elm')
        .use('elm')
          .loader('elm-webpack-loader')
          .options({
            cwd: root(),
            debug: true,
          })
          .end()
        .end()
      .end()
    .plugin('extract css')
      .use(ExtractCssPlugin, [{
        filename: '[name].css',
        chunkFilename: '[id].css',
      }])
      .end()
    .plugin('define')
      .use(DefinePlugin, [{
        'process.env': {
          MODE: JSON.stringify('development'),
        },
      }])
      .end()
}

// Production

if (build() === 'prod') {
  config
    .mode('production')
    .output
      .path(dist())
      .filename('[name].[hash].js')
      .publicPath('/')
      .end()
    .module
      .rule('elm')
        .use('elm')
          .loader('elm-webpack-loader')
          .options({
            cwd: root(),
            optimize: true,
          })
          .end()
        .end()
      .end()
    .plugin('extract css')
      .use(ExtractCssPlugin, [{
        filename: '[name].[hash].css',
        chunkFilename: '[id].[hash].css',
      }])
      .end()
    .plugin('define')
      .use(DefinePlugin, [{
        'process.env': {
          MODE: JSON.stringify('production'),
        },
      }])
      .end()
}

module.exports = config.toConfig()
