const path = require('path')
const { exec } = require('child_process')

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
