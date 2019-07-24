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
 * behavior in javascript.
 */

/* Donate */

const DONATE_REGEX = /^\/donate.*/

const DONATE_ANIMATION = 'bounce'

// the donate sections we will be watching for
const DONATE_ELEMENTS = [
  'donate-brave-section',
  'donate-patreon-section',
  'donate-crypto-section',
]

function createDonateScrollListener () {
  let throttled = false

  return function onDonateScroll ({ target }) {
    // throttling
    if (throttled) {
      return
    }
    throttled = true
    setTimeout(() => { throttled = false }, 20)

    // action
    const { scrollTop, offsetHeight: pageHeight } = target
    DONATE_ELEMENTS
      .slice(1)
      .forEach((id) => {
        const [img, content] = getDonateSection(id)
        const { offsetTop, offsetHeight: elHeight } = img
        console.log(`${scrollTop + pageHeight} < ${offsetTop + elHeight}`)
        if (scrollTop + pageHeight > offsetTop + elHeight) {
          animateIn(img)
          animateIn(content)
        } else {
          animateOut(img)
          animateOut(content)
        }
      })
  }
}

function getDonatePage () {
  return document.getElementById('donate-page')
}

function getDonateSection (id) {
  const section = document.getElementById(id)
  if (!section) { return null }
  return [
    section.querySelector('img'),
    section.querySelector('.content'),
  ]
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
 * animate element out of screen
 *
 * @param {HTMLElement} donateEl
 *
 * @returns {boolean} whether or not it was animated
 */
function animateOut (donateEl) {
  if (!donateEl) {
    return false
  }
  const [toRemove, toAdd] = animationName(donateEl)
  const { classList } = donateEl
  if (!classList.contains(toRemove)) {
    return false
  }
  donateEl.classList.remove(toRemove)
  donateEl.classList.add(toAdd)
  return true
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

/* Route Change */

function onRouteChange (route) {
  if (DONATE_REGEX.test(route)) {
    // set interval to attach listener
    const donateInterval = setInterval(() => {
      const page = getDonatePage()
      if (page) {
        page.addEventListener('scroll', createDonateScrollListener())
        const first = getDonateSection(DONATE_ELEMENTS[0])
        if (first) {
          first.forEach(animateIn)
        } else {
          console.error('failed to find first image')
        }
        clearInterval(donateInterval)
      }
    }, 100)
  }
}

export { onRouteChange }
