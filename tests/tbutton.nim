
import fidgetty
import fidgetty/button

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

proc exampleApp*() =
  frame "main":
    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
    Button:
      label "click me!"
      offset 4'em, 4'em
      size 10'em, 2'em #\
        # 10 font widths wide, 2 high
      onClick:
        echo "hi!"


startFidget(
  exampleApp,
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w=680, h=400,
  uiScale=2.0
)
