

import bumpy, fidget_dev, math, random
import std/strformat
import asyncdispatch # This is what provides us with async and the dispatcher
import times, strutils # This is to provide the timing output

import fidgetty
import fidgetty/themes
import fidgetty/[button, progressbar]
import fidgetty/[textinput]

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")


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
      centeredXY 90'pw, 90'ph
      stroke theme.outerStroke

      TextInputBind:
        value:
          self.textInput
        setup:
          # echo "text bind"
          box 20'pw, 20'ph, 40'pw, 40'ph
          # size 10'em, 2'em
          # position 10, 10
          # echo fmt" {40'pw=}, {40'ph=} "
          # centeredWH 40'pw, 40'ph
          # centeredH 40'ph

      # echo "text: ", $self.textInput


startFidget(
  wrapApp(exampleApp, ExampleApp),
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w=480, h=300,
  uiScale=2.0
)
