/*
 * Why Javascript?
 * ===============
 *
 * Elm is great, but it is still missing some of the API's that
 * javascript has available. This is one of those cases, where in
 * javascript we could query the heights of the elements. Another
 * solution would simply be to track the elements in javascript
 * and keep the state in elm via ports, but it's less overhead to
 * simply listen for route changes from elm, and handle the scroll
 * behavior in javascript. Also less bulletproof, so we have to be
 * mindful in our implementation.
 */

/**********************************************************************/
/*                               Donate                               */
/**********************************************************************/

const DONATE_REGEX = /^\/donate.*/
const DONATE_THROTTLE = 40

function createDonateScrollListener () {
  let throttled = false

  return function onDonateScroll ({ target }) {
    // throttling
    if (throttled) {
      return
    }
    throttled = true
    setTimeout(() => { throttled = false }, DONATE_THROTTLE)

    // action
    const { scrollTop, offsetHeight: pageHeight } = target
    Array.from(document.getElementsByClassName('animation-container'))
      .forEach((animationContainer) => {
        const animationTargets = Array.from(animationContainer.getElementsByClassName('animation-target'))
        const { offsetTop } = animationContainer
        if (scrollTop + pageHeight > offsetTop) {
          animationTargets.forEach(animateIn)
        }
      })
  }
}

function getDonatePage () {
  return document.getElementById('donate-page')
}

/**
 * Animate element into screen
 *
 * @param {HTMLElement} donateEl
 *
 * @returns {boolean} whether or not it was animated
 */
function animateIn (donateEl) {
  if (!donateEl) {
    return false
  }
  const [toAdd, toRemove] = animationName(donateEl)
  const { classList } = donateEl
  if (classList.contains(toAdd)) {
    return false
  }
  classList.remove(toRemove)
  classList.add(toAdd)
  classList.remove('hidden')
  return false
}

/**
 * extract animation className from element
 *
 * @param {HTMLElement} donateEl
 *
 * @returns {string}
 */
function animationName (donateEl) {
  const { classList } = donateEl
  const direction = classList.contains('left') ? 'Left' : 'Right'
  const animation = (() => {
    if (classList.contains('a-bounce')) {
      return 'bounce'
    }
    // default fade
    return 'fade'
  })()
  return [
    `${animation}In${direction}`,
    `${animation}Out${direction}`,
  ]
}

/**********************************************************************/
/*                              Listener                              */
/**********************************************************************/

function onRouteChange (route) {
  if (DONATE_REGEX.test(route)) {
    // set interval to attach listener
    const donateInterval = setInterval(() => {
      const page = getDonatePage()
      if (page) {
        const onDonateScroll = createDonateScrollListener()
        page.addEventListener('scroll', onDonateScroll)
        clearInterval(donateInterval)
      }
    }, 100)
  }
}

export { onRouteChange }
