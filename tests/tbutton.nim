
import fidgets
import fidgets/button

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

proc drawMain() =
  frame "main":
    Widget button:
      text: "click me!"


startFidget(drawMain, uiScale=2.0)
