import Events from '@shards/events'
import * as cache from '@interop/cache'
import * as network from '@interop/network'
import * as routes from '@interop/routes'
import * as fullscreen from '@interop/fullscreen'

/**
 * Abstraction over elm ports API
 */
function createPorts (app) {
  const self = {}

  // port subscriptions
  const subscriptions = Events()

  self.addListener = subscriptions.addListener

  function setupPortListener (name) {
    app.ports[`${name}Port`].subscribe((payload) => {
      subscriptions.emit(name, payload)
    })
  }

  // port updates
  const updates = Events()

  self.emit = updates.emit

  function setupPortUpdate (name) {
    updates.addListener(name, (payload) => {
      app.ports[`${name}Port`].send(payload)
    })
  }

  // network
  setupPortUpdate('onNetworkChange')

  // elm cache
  setupPortListener('onCacheChange')

  // fullscreen API
  setupPortListener('fullscreenElement')
  setupPortListener('exitFullscreen')
  setupPortUpdate('onFullscreenChange')

  // elm route
  setupPortListener('onRouteChange')
}

function apply (app) {
  const ports = createPorts(app)
  cache.apply(ports)
  network.apply(ports)
  routes.apply(ports)
  fullscreen.apply(ports)

  return flags
}

function flags () {
  let flags = {
    mode: process.env.MODE
  }
  flags = cache.addFlags(ports, flags)
  flags = network.addFlags(ports, flags)
  flags = routes.addFlags(ports, flags)
  flags = fullscreen.addFlags(ports, flags)
  return flags
}

export { apply, flags }
