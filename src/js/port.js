(function () {
  const { app, localStorage } = window
  app.ports.cacheSet.subscribe(function (data) {
    localStorage.setItem('elm-cache', data)
  })
})()
