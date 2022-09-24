import bumpy, fidget_dev
import std/strformat

import fidgetty
import fidgetty/themes
import fidgetty/textinput

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

type
  AppState = ref object
    ## this creates a new ref object type name using the
    ## capitalized proc name which is `ExampleApp` in this example. 
    ## This will be customizable in the future. 
    count: int
    value: float
    textInput: string

proc exampleApp*() =
  ## defines a stateful app widget
  ## 
  useState[AppState](self)

  setTitle(fmt"Fidget  Progress Example")
  textStyle theme

  box 1.Em, 1.Em, 100'vw - 2.Em, 100'vh - 2.Em
  font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
  fill "#F7F7F9"
  stroke theme.outerStroke

  rectangle "box":
    box 5'pp, 5'pp, 90'pp, 90'pp
    stroke theme.outerStroke

    TextInput:
      value self.textInput
      box 20'pp, 20'pp, 40'pp, 40'pp
    do -> ValueChange:
      Strings(val):
        self.textInput = val
        refresh()


startFidget(
  exampleApp,
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w=480, h=300,
  uiScale=2.0
)
