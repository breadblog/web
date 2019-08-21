function getFullscreen () {
  return !!document.fullscreenElement
}

function apply (ports) {
  ports.addListener('fullscreenElement', (className) => {
    const els = document.getElementsByClassName(className)
    if (els.length) {
      els[0].requestFullscreen()
    }
  })

  ports.addListener('exitFullscreen', () => {
    document.exitFullscreen()
  })

  document.addEventListener('fullscreenchange', ports.emit('onFullscreenChange', getFullscreen()))
}

function addFlags (flags) {
  return Object.assign({}, flags, {
    fullscreen: getFullscreen()
  })
}

export { apply, addFlags }
