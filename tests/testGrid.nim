
import fidget_dev, math, random
import std/strformat
import asyncdispatch # This is what provides us with async and the dispatcher
import times, strutils # This is to provide the timing output

import fidgetty
import fidgetty/themes
import fidgetty/[button, progressbar]


loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

template Grid(code: untyped) =
  frame "autoFrame":
    `code`

proc exampleApp*(
    myName : string,
): ExampleAppState {.appFidget.} =
  ## defines a stateful app widget
  ## 
  
  properties:
    ## this creates a new ref object type name using the
    ## capitalized proc name which is `ExampleApp` in this example. 
    ## This will be customizable in the future. 
    count: int
    value: float

  render:
    setWindowBounds(vec2(400, 200), vec2(800, 600))
    setTitle(fmt"Grid Example")
    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
    fill "#F7F7F9"
    cornerRadius 0.2'em

    # Setup CSS Grid Template
    gridTemplateRows  ["edge-t"] auto \
                      ["header"] 70'ui \
                      ["top"]    70'ui \
                      ["middle"] 30'ui \ 
                      ["bottom"] 1'fr \ 
                      ["footer"] auto \
                      ["edge-b"]

    gridTemplateColumns ["edge-l"]  40'ui \
                        ["button-la", "outer-l"] 150'ui \
                        ["button-lb"] 1'fr \
                        ["inner-m"] 1'fr \
                        ["button-ra"] 150'ui \
                        ["button-rb", "outer-r"] 40'ui \
                        ["edge-r"]

    boxOf parent

    rectangle "bar":
      # size 80'pw, 2.Em
      offset 10'pw, 10'ph
      gridRow "top" // "middle"
      gridColumn "outer-l" // "outer-r"

      self.value = (self.count.toFloat * 0.10) mod 1.0001
      Progressbar:
        value: self.value

    Button:
      label: fmt"Clicked1: {self.count:4d}"
      onClick: self.count.inc()
      setup:
        gridRow "middle" // "bottom"
        gridColumn "button-la" // "button-lb"

    Button:
      label: fmt"Clicked2: {self.count:4d}"
      onClick: self.count.inc()
      setup:
        gridRow "middle" // "bottom"
        gridColumn "button-ra" // "button-rb"
    

    ## uncomment to show track lines for grid
    # gridTemplateDebugLines true

var state = ExampleAppState(count: 2, value: 0.33)

proc drawMain() =
  frame "main":
    # we call exampleApp with a pre-made state
    # the `statefulWidget` always takes a `self` paramter
    # that that widgets state reference 
    # alternatively:
    #   exampleApp("basic widgets", state)
    ExampleApp:
      myName: "basic widgets"
      self: state


startFidget(
  drawMain,
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w=480, h=300,
  uiScale=2.0
)
