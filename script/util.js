const path = require('path')
const fs = require('fs')
const { exec } = require('child_process')
const { compileFile } = require('pug')

const Color = {
  blue: '\x1b[34m',
  red: '\x1b[31m',
  green: '\x1b[32m',
}
exports.Color = Color

const print = (msg, color = Color.blue) => { console.log(`${color}%s\x1b[0m`, msg) }
exports.print = print

const prod = () => process.env.BUILD === 'prod'
exports.prod = prod
const root = (...args) => path.resolve(__dirname, '..', ...args)
exports.root = root
const src = (...args) => root('src', ...args)
exports.src = src
const dist = (...args) => root('dist', ...args)
exports.dist = dist

const compile = async (build) => {
  return new Promise((resolve, reject) => {
    const command = `npm run make:${build}`
    exec(command, (err, stdout, stderr) => {
      if (err) {
        const errMsg = stderr
          .split('\n')
          .filter(line => !line.startsWith('npm ERR!'))
          .join('\n')
        reject(errMsg)
      } else {
        print('Compilation successful\n')
        resolve(stdout)
      }
    })
  })
}

const compileDev = () => compile('dev')
exports.compileDev = compileDev

const compileProd = () => compile('prod')
exports.compileProd = compileProd

// ---------------------------------- //
//                Pug                 //
// ---------------------------------- //

exports.compileHtml = (function () {
  return async () => {
    return new Promise((resolve, reject) => {
      const injections = {
        jsFile: prod() ? 'elm.min.js' : 'elm.js',
      }
      const compile = compileFile(src('index.pug'))
      const html = compile(injections)
      const outputPath = dist('index.html')

      fs.writeFile(outputPath, html, { encoding: 'utf8' }, (err) => {
        if (err) reject(err)
        else resolve()
      })
    })
  }
})()
