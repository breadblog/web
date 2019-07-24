const { migrate, createMigration } = createHelpers()

/********************************/
/*          Migrations          */
/********************************/

createMigration('0.0.1', '0.0.2')
createMigration('0.0.2', '0.0.3')
createMigration('0.0.3', '0.0.4')
createMigration('0.0.4', '0.0.5')
createMigration('0.0.5', '0.0.6')
createMigration('0.0.6', '0.0.7')
createMigration('0.0.7', '0.0.8')
createMigration('0.0.8', '0.0.9')
createMigration('0.0.9', '0.0.10')
createMigration('0.0.10', '0.0.11')
createMigration('0.0.11', '0.0.12')
createMigration('0.0.12', '0.0.13')
createMigration('0.0.13', '0.0.14')
createMigration('0.0.14', '0.0.15')
createMigration('0.0.15', '0.0.16')
createMigration('0.0.16', '0.0.17')
createMigration('0.0.17', '0.0.18')
createMigration('0.0.18', '0.0.19')
createMigration('0.0.19', '0.0.20')
createMigration('0.0.20', '0.0.21')
createMigration('0.0.21', '0.0.22')
createMigration('0.0.22', '0.0.23')
createMigration('0.0.23', '0.0.24')
createMigration('0.0.24', '0.0.25')
createMigration('0.0.25', '0.0.26')
createMigration('0.0.26', '0.0.27')

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

createMigration('0.0.27', '0.0.28')
createMigration('0.0.28', '0.0.29')
createMigration('0.0.29', '0.0.30')
createMigration('0.0.30', '0.0.32')
createMigration('0.0.32', '0.0.33')
createMigration('0.0.33', '0.0.34')
createMigration('0.0.34', '0.0.35')
createMigration('0.0.35', '0.0.36')

/********************************/
/*            Helpers           */
/********************************/

function createHelpers () {
  const migrations = {}

  /**
   * Add a migration to the list of migrations
   *
   * @param {string} version
   * @param {(value: object) => object} fn
   */
  function createMigration (start, end, fn) {
    migrations[start] = (val) => {
      const updated = fn ? fn(val) : val
      updated.version = end
      return updated
    }
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
    return !Object.keys(migrations).length
  }

  /**
   * Perform migration of value
   *
   * @param {object} value
   *
   * @returns {object}
   */
  function migrate (value) {
    if (!value || !value.version) { return null }
    let curr = value
    while (!migrationsEmpty()) {
      const step = getMigration(curr.version)
      // if "step" doesn't exist, we have completed the migration
      if (!step) { break }
      curr = step(curr)
    }

    return curr
  }

  return { migrate, createMigration }
}

export { migrate }
