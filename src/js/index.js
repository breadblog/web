import '@js/highlight'
import { Elm } from '@main'
import { apply, flags } from '@interop'
import '@font/firacode'
import '@font/indieflower'
import '@font/montserrat'

// Init
const app = Elm.Main.init({
  node: document.getElementsByTagName('body')[0],
  flags: flags()
})

// setup ports
apply(app)
