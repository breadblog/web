const instances = {}

function data ({ identifier }) {
  return instances[identifier]
}

const methods = {
  compare (other) {
    const a = data(this)
    const b = data(other)
    return a.str === b.str
  },
}

function Version (str) {
  // create the instance of version
  const self = Object.create(methods)
  // create identifier for this instance
  self.identifier = Symbol('version identifier')
  // initialize the data for this instance
  instances[self.identifier] = { str }
  // return the instance
  return self
}

export { Version }
