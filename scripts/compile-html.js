const { compileFile } = require('pug')
const path = require('path')
const fs = require('fs')

const prod = () => process.env.BUILD === 'prod'
const root = (...args) => path.resolve(__dirname, '..', ...args)
const src = (...args) => root('src', ...args)
const dist = (...args) => root('dist', ...args)

const injections = {
  jsFile: prod() ? 'elm.min.js' : 'elm.js',
}

const compile = compileFile(src('index.pug'))

const html = compile(injections)

const outputPath = dist('index.html')

fs.writeFile(outputPath, html, { encoding: 'utf8' }, (err) => {
  if (err) throw err
})
