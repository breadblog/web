(function () {
  const { localStorage } = window

  function getCache () {
    return localStorage.getItem('elm-cache')
  }

  window.elmFlags = {
    cache: getCache(),
  }
})()
