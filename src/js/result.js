/**
 * Javascript Result
 *
 * @param {*} value
 * @param {boolean} ok
 */
function Result (ok, value) {
  const self = { ok }
  if (ok) {
    self.err = null
    self.value = value
  } else {
    self.value = null
    self.err = value
  }

  return self
}

export { Result }
