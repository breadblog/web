import { Elm } from '@main'
import '@font/firacode'

const { localStorage } = window

// -- Flags
const flags = (function () {
  function getCache () {
    return JSON.parse(localStorage.getItem('elm-cache'))
  }

  return {
    cache: getCache(),
  }
})()

// -- Init
const app = Elm.Main.init({
  node: document.getElementsByTagName('body')[0],
  flags,
})

// -- Ports
;(function () {
  app.ports.cacheSet.subscribe(function (data) {
    localStorage.setItem('elm-cache', JSON.stringify(data))
  })
})()
