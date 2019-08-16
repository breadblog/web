import '@js/highlight'
import { Elm } from '@main'
import { migrate } from '@js/migrations'
import * as routes from '@js/routes'
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
    const cache = JSON.parse(localStorage.getItem('elm-cache'))
    const migrated = migrate(cache)

    return migrated
  }

  function getMode () {
    return process.env.MODE
  }

  return {
    cache: getCache(),
    mode: getMode(),
    network: getNetwork(),
    fullscreen: getFullscreen()
  }
})()

// -- Init
const app = Elm.Main.init({
  node: document.getElementsByTagName('body')[0],
  flags
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

  app.ports.changeRoutePort.subscribe((route) => {
    setTimeout(() => routes.onRouteChange(route))
  })

  app.ports.focus.subscribe(function (id) {
    setTimeout(() => {
      const element = document.getElementById(id)
      if (!element) { console.error(`failed to target ${id} to focus`) }
      element.focus()
    }, 0)
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
