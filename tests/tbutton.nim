
import fidgetty
import fidgetty/button

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

proc drawMain() =
  frame "main":
    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
    widget button:
      text: "click me!"
      onClick:
        echo "hi!"


startFidget(drawMain, w=680, h=400, uiScale=2.0)
