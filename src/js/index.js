import 'highlight.js/styles/gruvbox-dark'

import { Elm } from '@main'
import highlight from '@js/highlight'
import '@font/firacode'
import '@font/indieflower'
import '@font/montserrat'

const { localStorage } = window

function getNetwork () {
  return window.navigator.onLine
}


// -- Flags
const flags = (function () {
  function getCache () {
    return JSON.parse(localStorage.getItem('elm-cache'))
  }

  function getMode () {
    return process.env.MODE
  }

  return {
    cache: getCache(),
    mode: getMode(),
    network: getNetwork(),
  }
})()

// -- Init
const app = Elm.Main.init({
  node: document.getElementsByTagName('body')[0],
  flags,
})

// -- Port subscriptions
;(function () {
  app.ports.setCachePort.subscribe(function (data) {
    localStorage.setItem('elm-cache', JSON.stringify(data))
  })
})()

// -- Port updates
;(function () {
  function onNetworkChange () {
    app.ports.setNetworkPort.send(getNetwork())
  }

  window.addEventListener('online', onNetworkChange)
  window.addEventListener('offline', onNetworkChange)
})()

// -- Highlight
document.addEventListener('DOMContentLoaded', highlight)
