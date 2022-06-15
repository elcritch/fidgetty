
import bumpy, fidget, math, random
import std/strformat
import asyncdispatch # This is what provides us with async and the dispatcher
import times, strutils # This is to provide the timing output

import fidgetty
import fidgetty/themes
import fidgetty/[button, progressbar]

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

template Grid(code: untyped) =
  frame "autoFrame":
    # autoOrg()

    # layout lmVertical
    # counterAxisSizingMode csAuto
    # constraints cMin, cStretch
    # itemSpacing 15

    `code`


proc exampleApp*(
    myName {.property: name.}: string,
): ExampleApp {.appFidget.} =
  ## defines a stateful app widget
  ## 
  
  properties:
    ## this creates a new ref object type name using the
    ## capitalized proc name which is `ExampleApp` in this example. 
    ## This will be customizable in the future. 
    count: int
    value: float

  render:
    setTitle(fmt"Fidget Animated Progress Example - {myName}")
    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
    fill "#F7F7F9"

    group "center":
      # box 100, 0, 80'vw, 100'vw
      paddingXY 1.Em
      cornerRadius 0.2'em
      # autoOrg()
      # layout lmVertical
      # counterAxisSizingMode csAuto

      fill "#DFDFE0"
      strokeWeight 1

      Vertical:
        boxOf parent
        itemSpacing 2.Em

        rectangle "bar":
          size 80.WPerc, 2.Em
          offset 1.Em, 1.Em
          # constraints cScale, cMin
          self.value = (self.count.toFloat * 0.10) mod 1.0001
          Progressbar:
            value: self.value

        # Horizontal:
        rectangle "area1":
          strokeLine 1.0, "#000000", 0.87
          itemSpacing 2.Em

          rectangle "area1":
            # size 12.Em, 4.Em
            paddingXY 4.Em, 4.Em
            # offset 25.WPerc, 25.HPerc
            # constraints cScale, cScale
            Button:
              label: fmt"Clicked1: {self.count:4d}"
              onClick: self.count.inc()

          rectangle "area1":
            # size 12.Em, 4.Em
            paddingXY 4.Em, 4.Em
            # offset 75.WPerc, 25.HPerc
            # constraints cScale, cScale
            Button:
              label: fmt"Clicked2: {self.count:4d}"
              onClick: self.count.inc()

        # Horizontal:
        rectangle "area1":
          strokeLine 1.0, "#000000", 0.87
          itemSpacing 2.Em

          rectangle "area2":
            size 8.Em, 2.Em
            # offset 25.WPerc, 75.HPerc
            # constraints cScale, cScale
            Button:
              label: fmt"Clicked3: {self.count:4d}"
              onClick: self.count.inc()

          rectangle "area2":
            size 8.Em, 2.Em
            # offset 75.WPerc, 75.HPerc
            # constraints cScale, cScale
            Button:
              label: fmt"Clicked4: {self.count:4d}"
              onClick: self.count.inc()


var state = ExampleApp(count: 2, value: 0.33)

const callform {.intdefine.} = 2

proc drawMain() =
  frame "main":
    # we call exampleApp with a pre-made state
    # the `statefulWidget` always takes a `self` paramter
    # that that widgets state reference 
    # alternatively:
    #   exampleApp("basic widgets", state)
    widget exampleApp:
      name: "basic widgets"
      self: state


startFidget(
  drawMain,
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w=480, h=300,
  uiScale=2.0
)
