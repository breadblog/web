function getNetwork () {
  return window.navigator.onLine
}

function apply (ports, flags) {
  function onNetworkChange () {
    ports.emit('onNetworkChange', getNetwork())
  }

  window.addEventListener('online', onNetworkChange)
  window.addEventListener('offline', onNetworkChange)

  return Object.assign({}, flags, {
    network: getNetwork()
  })
}

export default apply
