import { migrate } from "@js/migrations"

function getCache () {
  return JSON.parse(localStorage.getItem('elm-cache'))
}

function setCache (cache) {
  localStorage.setItem('elm-cache', JSON.stringify(cache))
}

function apply (ports) {
  ports.addListener('onCacheChange', setCache)
}

function addFlags (flags) {
  return Object.assign({}, flags, {
    cache: migrate(getCache())
  })
}

export { apply, addFlags }
