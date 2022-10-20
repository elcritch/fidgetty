
import fidgetty
import fidgetty/button

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

proc exampleApp*() =
  frame "main":
    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
    fill whiteColor
    rectangle "test":
      box 2'em, 2'em, 100'vw - 4'em, 100'vh - 4'em
      cornerRadius 1'em
      fill "#dedede"


startFidget(
  exampleApp,
  setup = 
    when defined(demoBulmaTheme): bulmaTheme
    else: grayTheme,
  w=680, h=400
)
