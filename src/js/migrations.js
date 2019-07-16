import { Version } from '@js/version'
import { findMap, isTruthy } from '@js/util'

// TODO: how to perform upgrade after "createMigration"?
// maybe have to specify what version to upgrade to?
// not ideal but not terrible either
// what about missing migrations?

/********************************/
/*          Migrations          */
/********************************/

/*
 * 0.0.28
 *
 * { version : Version
 * , theme : Theme
 * , tags : List Tag
 * , authors : List Author
 * , postPreviews : List (Post Core Preview)
 * , user : Maybe UUID
 * }
 */

createMigration('0.0.28', (value) => {

})


/*
 * 0.0.29
 *
 * { version : Version
 * , theme : Theme
 * , tags : List Tag
 * , authors : List Author
 * , postPreviews : List (Post Core Preview)
 * , user : Maybe UUID
 * }
 */

/********************************/
/*            Helpers           */
/********************************/

const migrations = {}

/**
 * Add a migration to the list of migrations
 *
 * @param {string} version
 * @param {(value: object) => object} fn
 */
function createMigration (version, fn) {
  migrations[version] = fn
}

/**
 * Get a migration from the list of migrations
 *
 * @param {string} version
 *
 * @returns {(value: object) => object}
 */
function getMigration (version) {
  const migration = migrations[version]
  delete migrations[version]
  return migration
}

/**
 * check if migrations are empty
 *
 * @returns {boolean}
 */
function migrationsEmpty () {
  return !!Object.keys(migrations).length
}

/**
 * Perform migration of value
 *
 * @param {object} value
 *
 * @returns {Result<*, object>}
 */
function migrate (value) {
  let curr = value
  while (!migrationsEmpty()) {
    const versionRes = Version(curr.version)
    if (!versionRes.ok) {
      return versionRes
    }
    const version = versionRes.value
    const upgrades = version.upgrades()
    const migration = findMap(
      v => getMigration(v),
      isTruthy,
      upgrades,
    )
    if (migration) {
      curr = migration(curr)
    }
  }

  return curr
}

export { migrate }
