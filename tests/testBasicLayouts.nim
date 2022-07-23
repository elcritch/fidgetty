
import fidget, math, random
import std/strformat
import asyncdispatch # This is what provides us with async and the dispatcher
import times, strutils # This is to provide the timing output

import fidgetty
import fidgetty/themes
import fidgetty/[button, progressbar]

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

proc loadMain() =
  setWindowBounds(vec2(300, 200), vec2(600, 400))

template Grid(code: untyped) =
  frame "autoFrame":
    autoOrg()

    # layout lmVertical
    # counterAxisSizingMode csAuto
    # constraints cMin, cStretch
    # itemSpacing 15

    `code`


proc exampleApp*(): ExampleApp {.appFidget.} =
  ## defines a stateful app widget
  ## 
  
  properties:
    ## this creates a new ref object type name using the
    ## capitalized proc name which is `ExampleApp` in this example. 
    ## This will be customizable in the future. 
    count: int
    value: float

  render:
    setTitle("Fidget Animated Progress Example ")
    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
    fill "#F7F7F9"

    group "center":
      paddingXY 1.Em
      cornerRadius 0.2'em
      autoOrg()
      # layout lmVertical
      # counterAxisSizingMode csAuto

      fill "#DFDFE0"
      strokeWeight 1

      Grid:
        boxOf parent
        itemSpacing 2.Em

        rectangle "bar":
          size 80'vw, 2.Em
          offset 1.Em, 1.Em
          # constraints cScale, cMin

          self.value = (self.count.toFloat * 0.10) mod 1.0001
          Progressbar:
            value: self.value

        Horizontal:
          itemSpacing 2.Em
          rectangle "area1":
            size 8.Em, 2.Em
            offset 2.Em, 4.Em
            # constraints cScale, cScale
            Button:
              label: fmt"Clicked2: {self.count:4d}"
              setup:
                size 8.Em, 2.Em
              onClick: self.count.inc()

          rectangle "area0":
            size 8.Em, 2.Em
            offset 3.Em, 7.Em
            # constraints cScale, cScale
            Button:
              label: fmt"Clicked4: {self.count:4d}"
              setup:
                size 8.Em, 2.Em
              onClick: self.count.inc()


startFidget(
  wrapApp(exampleApp, ExampleApp),
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w=480, h=300,
  uiScale=2.0
)
