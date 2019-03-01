import hljs from 'highlight.js'
import javascript from 'highlight.js/lib/languages/javascript'
import bash from 'highlight.js/lib/languages/bash'
import css from 'highlight.js/lib/languages/css'
import markdown from 'highlight.js/lib/languages/markdown'
import elm from 'highlight.js/lib/languages/elm'
import go from 'highlight.js/lib/languages/go'
import python from 'highlight.js/lib/languages/python'
import haskell from 'highlight.js/lib/languages/haskell'
import scss from 'highlight.js/lib/languages/scss'
import dockerfile from 'highlight.js/lib/languages/dockerfile'
import http from 'highlight.js/lib/languages/http'
import sql from 'highlight.js/lib/languages/sql'
import pgsql from 'highlight.js/lib/languages/pgsql'
import properties from 'highlight.js/lib/languages/properties'
import json from 'highlight.js/lib/languages/json'
import diff from 'highlight.js/lib/languages/diff'
import ini from 'highlight.js/lib/languages/ini'
import xml from 'highlight.js/lib/languages/xml'
import cpp from 'highlight.js/lib/languages/cpp'

hljs.registerLanguage('javascript', javascript)
hljs.registerLanguage('bash', bash)
hljs.registerLanguage('css', css)
hljs.registerLanguage('markdown', markdown)
hljs.registerLanguage('elm', elm)
hljs.registerLanguage('go', go)
hljs.registerLanguage('python', python)
hljs.registerLanguage('haskell', haskell)
hljs.registerLanguage('scss', scss)
hljs.registerLanguage('dockerfile', dockerfile)
hljs.registerLanguage('http', http)
hljs.registerLanguage('sql', sql)
hljs.registerLanguage('pgsql', pgsql)
hljs.registerLanguage('properties', properties)
hljs.registerLanguage('json', json)
hljs.registerLanguage('diff', diff)
hljs.registerLanguage('ini', ini)
hljs.registerLanguage('html', xml)
hljs.registerLanguage('xml', xml)
hljs.registerLanguage('cpp', cpp)

export default () => {
  hljs.initHighlighting()
}
