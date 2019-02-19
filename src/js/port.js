(function () {
  app.ports.cacheSet.subscribe(function (data) {
    localStorage.setItem('elm-cache', data)
  })
})()
