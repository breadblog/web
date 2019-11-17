import '@js/highlight'
import { Elm } from '@main'
import { migrate } from '@js/migrations'
import '@font/firacode'
import '@font/indieflower'
import '@font/montserrat'
import Maybe from '@shards/maybe'

/**
 * Gets the current network status
 * @returns {bool}
 */
function getNetwork () {
  return window.navigator.onLine
}

/**
 * Gets the current fullscreen status
 * @returns {bool}
 */
function getFullscreen () {
  return !!document.fullscreenElement
}

/**
 * Gets application mode
 *
 * @returns {string}
 */
function getMode () {
  return process.env.MODE
}

/**
 * Gets elm cache
 *
 * @returns {Result<Cache>}
 */
function getCache () {
  const cache = JSON.parse(window.localStorage.getItem('elm-cache'))
  return migrate(cache).match({
    onOk: m => m,
    onErr (err) {
      console.error('failed to migrate cache')
      console.error(err)
    },
  })
}

function subscribe (app, name, fn) {
  const portName = `${name}Port`
  Maybe(app.ports[portName]).match(
    (port) => {
      port.subscribe(fn)
    },
    () => {
      console.error(`no such subscribe port: ${portName}`)
    },
  )
}

function update (app, name, payload) {
  const portName = `${name}Port`
  Maybe(app.ports[portName]).match(
    (port) => {
      port.send(payload)
    },
    () => {
      console.error(`no such update port: ${portName}`)
    }
  )
}

// -- Flags
const flags = {
  cache: getCache(),
  mode: getMode(),
  network: getNetwork(),
  fullscreen: getFullscreen(),
}

// -- Init
const app = Elm.Main.init({
  node: document.getElementsByTagName('body')[0],
  flags,
})

setTimeout(() => console.log(app), 10000)

// -- Port subscriptions
;(function () {
  subscribe(app, 'cacheUpdate', function (data) {
    window.localStorage.setItem('elm-cache', JSON.stringify(data))
  })

  subscribe(app, 'fullscreenElement', function (className) {
    const els = document.getElementsByClassName(className)
    if (els.length) {
      els[0].requestFullscreen()
    }
  })

  subscribe(app, 'exitFullscreen', function () {
    document.exitFullscreen()
  })
})()

// -- Port updates
;(function () {
  function onNetworkChange () {
    update(app, 'networkUpdate', getNetwork())
  }

  window.addEventListener('online', onNetworkChange)
  window.addEventListener('offline', onNetworkChange)

  function onFullscreenChange () {
    update(app, 'fullscreenUpdate', getFullscreen())
  }

  document.addEventListener('fullscreenchange', onFullscreenChange)
})()
