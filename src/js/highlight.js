import hljs, { registerLanguage } from 'highlight.js'
import 'highlight.js/styles/gruvbox-dark'
import javascript from 'highlight.js/lib/languages/javascript'
import css from 'highlight.js/lib/languages/css'
import elm from 'highlight.js/lib/languages/elm'
import elixir from 'highlight.js/lib/languages/elixir'
import go from 'highlight.js/lib/languages/go'
import haskell from 'highlight.js/lib/languages/haskell'
import scss from 'highlight.js/lib/languages/scss'
import dockerfile from 'highlight.js/lib/languages/dockerfile'
import sql from 'highlight.js/lib/languages/sql'
import json from 'highlight.js/lib/languages/json'
import ini from 'highlight.js/lib/languages/ini'
import xml from 'highlight.js/lib/languages/xml'

registerLanguage('javascript', javascript)
registerLanguage('css', css)
registerLanguage('elm', elm)
registerLanguage('go', go)
registerLanguage('elixir', elixir)
registerLanguage('haskell', haskell)
registerLanguage('scss', scss)
registerLanguage('dockerfile', dockerfile)
registerLanguage('sql', sql)
registerLanguage('json', json)
registerLanguage('ini', ini)
registerLanguage('html', xml)
registerLanguage('xml', xml)

// simply adding "hljs" to window is enough to allow
// elm-explorations/markdown to automatically highlight
// code blocks
window.hljs = hljs
