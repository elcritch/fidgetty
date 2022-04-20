
import fidgets
import fidgets/button

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

proc drawMain() =
  frame "main":
    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
    Widget button:
      text: "click me!"
      click:
        echo "hi!"


startFidget(drawMain, uiScale=2.0)
