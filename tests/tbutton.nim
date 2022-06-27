
import fidgetty
import fidgetty/button

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

proc exampleApp*(): ExampleApp {.appFidget.} =
  properties:
    count2: int

  render:
    frame "main":
      font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
      Button:
        label: "click me!"
        onClick:
          echo "hi!"


startFidget(
  wrapApp(exampleApp, ExampleApp),
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w=680, h=400,
  uiScale=2.0
)
