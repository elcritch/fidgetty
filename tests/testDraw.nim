import bumpy, fidget, math, random
import std/strformat
import asyncdispatch # This is what provides us with async and the dispatcher
import times, strutils # This is to provide the timing output

import fidgetty
import fidgetty/themes
import fidgetty/[button, progressbar]
import fidgetty/[textinput]

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

var idx = 0.0'f32

proc exampleApp*(): ExampleApp {.appFidget.} =
  ## defines a stateful app widget
  ## 
  
  properties:
    ## this creates a new ref object type name using the
    ## capitalized proc name which is `ExampleApp` in this example. 
    ## This will be customizable in the future. 
    count: int
    value: float
    textInput: string

  render:
    setTitle(fmt"Fidget  Progress Example")
    textStyle theme

    box 1.Em, 1.Em, 100'vw - 2.Em, 100'vh - 2.Em
    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
    fill "#F7F7F9"
    stroke theme.outerStroke

    rectangle:
      centeredWH 90'pw, 90'ph
      stroke theme.outerStroke
  
      drawable:
        strokeLine 3'f32, "#000000"
        idx += 0.5
        if idx >= 100:
          idx = 0
        current.poly.setLen(0)
        for i in 0..80:
          let t = i.float32 + idx
          current.poly.add vec2(5*t+10, 200+100.0*sin(1.0/5.0 * t))

startFidget(
  wrapApp(exampleApp, ExampleApp),
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w=480, h=300,
  uiScale=2.0
)
