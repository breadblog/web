const express = require('express')
const fallback = require('express-history-api-fallback')
const chokidar = require('chokidar')

const {
  src,
  root,
  dist,
  print,
  Color,
  compileDev,
  compileHtml,
} = require('./util')

const app = express()
const port = 9080

app.use(express.static(root('assets')))
app.use(express.static(dist()))
app.use(fallback(dist('index.html')))

app.get('/**/(*).js$', (req, res) => {
  res.sendFile(dist(req.params[0]))
})

;(async function () {
  const onChange = async () => {
    try {
      await compileDev()
      await compileHtml()
    } catch (err) {
      print('Error has occurred:', Color.red)
      print(err.message || err, Color.green)
    }
  }
  try {
    await compileDev()
    await compileHtml()

    app.listen(port, () => print(`Development server running on localhost:${port}`))

    chokidar.watch([root('assets'), src()], { ignoreInitial: true })
      .on('change', onChange)
      .on('add', onChange)
      .on('addDir', onChange)
  } catch (err) {
    print('Error has occurred:', Color.red)
    print(err.message || err, Color.red)
  }
})()
