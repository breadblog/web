const { compileFile } = require('pug')
const fs = require('fs')
const { prod, dist, src } = require('./util')

const injections = {
  jsFile: prod() ? 'elm.min.js' : 'elm.js',
}

const compile = compileFile(src('index.pug'))

const html = compile(injections)

const outputPath = dist('index.html')

fs.writeFile(outputPath, html, { encoding: 'utf8' }, (err) => {
  if (err) throw err
})
