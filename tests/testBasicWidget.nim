
import bumpy, fidget, math, random
import std/strformat
import asyncdispatch # This is what provides us with async and the dispatcher
import times, strutils # This is to provide the timing output

import fidgets
import fidgets/[button, progressbar]

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

proc exampleApp*(
    myName {.property: name.}: string,
): ExampleApp {.appFidget.} =
  ## defines a stateful app widget
  ## 
  ## `exampleApp` will be transformed to also take the basic
  ## widget parameters:
  ##  - self: ExampleApp
  ##  - setup: proc()
  ##  - post: proc()
  ## 
  ## These parameters support using the widget with the properties
  ## syntax. See the `button` examples below. The property name is
  ## either the argument name or can be set using the `property` pragma
  ## like show with `myName` that will provide a property of `name`.
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
      box 50, 0, 100.Vw - 100, 100.Vh
      orgBox 50, 0, 100.Vw, 100.Vw
      fill "#DFDFE0"
      strokeWeight 1

      self.value = (self.count.toFloat * 0.10) mod 1.0001
      progressbar(self.value, fmt"Progress: {self.value:4.2}") do:
        box 10.WPerc, 20, 80.WPerc, 2.Em

      horizontal:
        # creates an horizontal spacing box

        box 90.WPerc - 16.Em, 100, 8.Em, 2.Em
        itemSpacing 0.Em

        # Click to make the bar increase
        # basic syntax just calling a proc
        if button(fmt"Clicked1: {self.count:4d}"):
          self.count.inc()

        # Alternate format using `Widget` macro that enables
        # a YAML like syntax using property labels
        # (see parameters on `button` widget proc)
        widget button:
          text: fmt"Clicked2: {self.count:4d}"
          onClick: self.count.inc()

        # current limit on Widget macros is that all args
        # must be called as properties, no mix and match
        #
        # i.e. this doesn't work (yet):
        #     Widget button(fmt"Clicked2: {self.count:4d}"):
        #       onClick: self.count.inc()

      vertical:
        # creates a vertical spacing box

        box 10.WPerc, 160, 8.Em, 2.Em
        itemSpacing 1.Em

        # Button:
        #   # default alias of `Widget button`
        #   # only created for non-stateful widgets
        #   text: fmt"Clicked3: {self.count:4d}"
        #   setup: size 8.Em, 2.Em
        #   onClick: self.count.inc()

        widget button:
          text: fmt"Clicked4: {self.count:4d}"
          setup: size 8.Em, 2.Em
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


startFidget(drawMain, w=640, h=400, uiScale=2.0)