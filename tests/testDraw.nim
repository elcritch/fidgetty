import bumpy, fidget_dev, math, random
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
    time: float
    done: bool
    textInput: string
    ticks: Future[void] = emptyFuture()

  render:
    setTitle(fmt"Fidget  Progress Example")
    textStyle theme

    box 1.Em, 1.Em, 100'vw - 2.Em, 100'vh - 2.Em
    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
    fill "#F7F7F9"
    stroke theme.outerStroke

    proc ticker(self: ExampleApp) {.async.} =
      while not self.done:
        self.time += 13.0
        refresh()
        await sleepAsync(32)
    proc ticker(self: ExampleApp) {.async.} =
      while not self.done:
        self.time += 13.0
        refresh()
        await sleepAsync(32)

    if self.ticks.isNil or self.ticks.finished:
      echo "ticker: ", self.count
      self.ticks = ticker(self)

    rectangle:
      centeredWH 90'pw, 90'ph
      strokeLine 3, "#000000"
  
      drawable:
        # Drawable node's don't draw a normal rectangle. Instead they draw
        # a list of points set in `current.points` using the nodes fill/stroke. 
        # The size of the drawable node is used for the point sizes, etc. 
        # Note: experimental
        fill "#000000"
        size 2, 2

        current.points.setLen(3200)
        for i in 0..<3200:
          let t = i.float32 + self.time
          if i mod 1 == 0:
            current.points[i].x = 0.125*i.UICoord+0
            current.points[i].y = 50.0'ui + 60.0*sin(1.0/12.0 * 0.125 * t) + 50.0

startFidget(
  wrapApp(exampleApp, ExampleApp),
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w=480, h=300,
  uiScale=2.0
)
