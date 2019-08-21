function open () {
  const request = window.indexedDB.open('db', 1)

  return new Promise((resolve, reject) => {
    request.addEventListener('error', (ev) => {
      reject(ev)
    })

    request.addEventListener('success', (ev) => {
      resolve(ev)
    })
  })
}

export default open
