function isTruthy (value) {
  return !!value
}

function findMap (map, predicate, list) {
  for (const val of list) {
    const mapped = map(val)
    const found = predicate(mapped)
    if (found) {
      return mapped
    }
  }

  return null
}

export { isTruthy, findMap }
