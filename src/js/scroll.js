/* Donate */

const DONATE_REGEX = /^\/donate.*/

const DONATE_ELEMENTS = [
  'donate-brave-section',
  'donate-patreon-section',
  'donate-crypto-section',
]

function onDonateScroll () {
  console.log('onDonateScroll event')
}

/* Route Change */

function onRouteChange (route) {
  console.log(route)
  if (DONATE_REGEX.test(route)) {
    // set interval to attach listener
    const donateInterval = setInterval(() => {
      const elements = document.getElementById('donate-page')
      if (elements.length) {
        elements[0].addEventListener('scroll', onDonateScroll)
        clearInterval(donateInterval)
      }
    }, 100)
  }
}

export { onRouteChange }
