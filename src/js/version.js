import { Result } from '@js/result'

function parse (str) {
  const regex = /^(\d+)\.(\d+)\.(\d+)$/
  const matches = regex.exec(str)
  if (!matches) {
    return Result(false, `failed to parse version ${str}`)
  }

  const ints = matches
    .slice(1)
    .map(Number)

  const invalidInts = ints
    .any(Number.isNaN)

  if (invalidInts) {
    return Result(false, `failed to parse ints from version ${str}`)
  }

  return Result(true, ints)
}

function stringFrom (major, minor, patch) {
  return `${major}.${minor}.${patch}`
}

function Version (str) {
  const data = {}
  const res = parse(str)
  if (!res.ok) {
    return res
  }
  (() => {
    const v = res.value
    data.major = v[0]
    data.minor = v[1]
    data.patch = v[2]
  })()

  const self = {
    upgrades () {
      const { major, minor, patch } = data
      return [
        stringFrom(major, minor, patch + 1),
        stringFrom(major, minor + 1, patch),
        stringFrom(major + 1, minor, patch),
      ]
    },

    /**
     * compare with string version
     *
     * @param {string} str
     *
     * @returns {Result<string, boolean>}
     */
    compare (str) {
      const a = self
      const bRes = Version(str)
      if (!bRes.ok) {
        return bRes
      }
      const b = bRes.value
      return a.toString() === b.toString()
    },

    /**
     * convert to string
     *
     * @returns {string}
     */
    toString () {
      const { major, minor, patch } = data
      return stringFrom(major, minor, patch)
    },
  }

  return Result(true, self)
}

export { Version }
