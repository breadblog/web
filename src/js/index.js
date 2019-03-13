import 'highlight.js/styles/gruvbox-dark'

import { Elm } from '@main'
import highlight from '@js/highlight'
import '@font/firacode'
import '@font/indieflower'
import '@font/montserrat'

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
  app.ports.setCache.subscribe(function (data) {
    localStorage.setItem('elm-cache', JSON.stringify(data))
  })
})()

// -- Highlight
document.addEventListener('DOMContentLoaded', highlight)
