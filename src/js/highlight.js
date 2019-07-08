import hljs from 'highlight.js/lib/highlight'
import javascript from 'highlight.js/lib/languages/javascript'
import css from 'highlight.js/lib/languages/css'
import elm from 'highlight.js/lib/languages/elm'
import go from 'highlight.js/lib/languages/go'
import haskell from 'highlight.js/lib/languages/haskell'
import scss from 'highlight.js/lib/languages/scss'
import dockerfile from 'highlight.js/lib/languages/dockerfile'
import sql from 'highlight.js/lib/languages/sql'
import json from 'highlight.js/lib/languages/json'
import ini from 'highlight.js/lib/languages/ini'
import xml from 'highlight.js/lib/languages/xml'

hljs.registerLanguage('javascript', javascript)
hljs.registerLanguage('css', css)
hljs.registerLanguage('elm', elm)
hljs.registerLanguage('go', go)
hljs.registerLanguage('haskell', haskell)
hljs.registerLanguage('scss', scss)
hljs.registerLanguage('dockerfile', dockerfile)
hljs.registerLanguage('sql', sql)
hljs.registerLanguage('json', json)
hljs.registerLanguage('ini', ini)
hljs.registerLanguage('html', xml)
hljs.registerLanguage('xml', xml)

function highlight (className) {
  const elements = document.querySelectorAll(`.${className} pre>code`)
  elements.forEach(el => hljs.highlightBlock(el))
}

function highlightAll () {
  hljs.initHighlighting()
}

export { highlightAll, highlight }
