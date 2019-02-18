(function () {
  app.ports.cache.subscribe(function (data) {
    const { key, value } = data
    localStorage.setItem(key, value)
  })
})()
