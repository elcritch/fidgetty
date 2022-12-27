
import fidgetty
import fidgetty/button
import fidgetty/fidget_dev/common

import patty

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

proc exampleApp*() =
  frame "main":
    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
    fill whiteColor
    rectangle "test":
      box 2'em, 2'em, 100'vw - 4'em, 100'vh - 4'em
      cornerRadius 1'em
      fill "#dedede"

import macros

static:
  echo lispRepr(quote do:
    let m = 1
    let x = m[]
  )

expandMacros:
  proc test() =
    let evt = MouseEvent(kind: evClick)
    match evt[]:
      evClick:
        echo "ev clicks"
      _:
        echo "other"
        discard

  # let evt = Shape(kind: Circle, r: 3.0)
  # match evt[]:
  #   Circle():
  #     echo "ev click"
  #   _:
  #     echo "other"
  #     discard

test()

startFidget(
  exampleApp,
  setup = 
    when defined(demoBulmaTheme): bulmaTheme
    else: grayTheme,
  w=680, h=400
)
