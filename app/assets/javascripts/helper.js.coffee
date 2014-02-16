$ ->
  window.hypem.getHiddenProp = ->
    prefixes = [
      "webkit"
      "moz"
      "ms"
      "o"
    ]

    return "hidden"  if "hidden" of document

    i = 0

    while i < prefixes.length
      return prefixes[i] + "Hidden"  if (prefixes[i] + "Hidden") of document
      i++

    null

  window.hypem.isHidden = ->
    prop = hypem.getHiddenProp()
    return false  unless prop
    document[prop]