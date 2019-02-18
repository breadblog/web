(function () {
  function getCache () {
    function get (key) {
      return localStorage.getItem(key)
    }
    const cache = {
      version: get('version'),
    }
  }

  window.elmFlags = {
    cache: getCache(),
  }
})()
