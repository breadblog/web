import 'animate.css'

import '@js/highlight'
import { Elm } from '@main'
import '@font/firacode'
import '@font/indieflower'
import '@font/montserrat'

const { localStorage } = window

function getNetwork () {
  return window.navigator.onLine
}

function getFullscreen () {
  return !!document.fullscreenElement
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
    fullscreen: getFullscreen(),
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

  app.ports.fullscreenElement.subscribe(function (className) {
    const els = document.getElementsByClassName(className)
    if (els.length) {
      els[0].requestFullscreen()
    }
  })

  app.ports.exitFullscreen.subscribe(function () {
    document.exitFullscreen()
  })
})()

// -- Port updates
;(function () {
  function onNetworkChange () {
    app.ports.getNetworkPort.send(getNetwork())
  }

  window.addEventListener('online', onNetworkChange)
  window.addEventListener('offline', onNetworkChange)

  function onFullscreenChange () {
    app.ports.getFullscreenPort.send(getFullscreen())
  }

  document.addEventListener('fullscreenchange', onFullscreenChange)
})()
