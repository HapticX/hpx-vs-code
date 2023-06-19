import std/jsffi

type
  Util* = ref UtilObj
  UtilObj {.importc.} = object of JsRoot

  TextEncoder* = ref object

# util
proc newTextEncoder*(u: Util): TextEncoder {.
    importcpp: "(new #.TextEncoder(@))".}

# TextEncoder
proc encode*(enc: TextEncoder, content: cstring): seq[uint8] {.importcpp.}

var util*: Util = require("util").toJs().to(Util)
