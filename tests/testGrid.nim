
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
    cornerRadius 0.2'em

    Grid:
      boxOf parent

      rectangle "bar":
        size 80'pw, 2.Em
        offset 10'pw, 10'ph

        self.value = (self.count.toFloat * 0.10) mod 1.0001
        Progressbar:
          value: self.value

      rectangle "bar":
        offset 0, 3.Em
        size 80'pw, 100'ph - 3.Em

        Button:
          label: fmt"Clicked1: {self.count:4d}"
          onClick: self.count.inc()
          setup:
            size 8.Em, 2.Em
            offset 80'pw - 4.Em, 30'ph - 1.Em

        Button:
          label: fmt"Clicked2: {self.count:4d}"
          setup:
            size 8.Em, 2.Em
            offset 80'pw - 4.Em, 80'ph - 1.Em
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
  load=loadMain,
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w=480, h=300,
  uiScale=2.0
)
