
import std/[math, strformat]

import fidgetty
import fidgetty/themes
import fidgetty/[button, progressbar]
import fidgetty/[tabview]

import print

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

type
  GridApp = ref object
    ## this creates a new ref object type name using the
    ## capitalized proc name which is `ExampleApp` in this example. 
    ## This will be customizable in the future. 
    count: int
    value: float
    pipDrag: bool
    pipPos: Position
    barOffset: float
    barVal: float

proc new*(_: typedesc[GridApp]): GridApp =
  new result

proc drawMain() =
  # echo "\n\n=================================\n"
  frame "main":
    useState[GridApp](self)
  
    setWindowBounds(vec2(400, 200), vec2(800, 600))
    setTitle(fmt"Grid Example")
    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
    fill "#F7F7F9"
    cornerRadius 0.2'em

    # Setup CSS Grid Template
    box 1'em, 1'em, 100'vw - 2'em, 100'vh - 2'em

    TabView:
      clipContent true
      cornerRadius 0.5'em
      fill rgba(66, 177, 44, 167).to(Color).spin(100.0) * 0.2

      tab "menu":
        cornerRadius 0.2'em
        Vertical:
          itemSpacing 1'em
          size 100'pp, 100'pp

          Button:
            size 100'pp, 2'em
            disabled true
            label fmt"Width: {parent.screenbox.w.float:6.0f}"

          Button:
            size 100'pp, 2'em
            disabled true
            label fmt"Width: {parent.screenbox.w.float:6.0f}"

      tab "main":
        size 10'em, 10'em
        Vertical:
          itemSpacing 1'em
          size 10'em, 10'em
          self.value = (self.count.toFloat * 0.10) mod 1.0001

          Button:
            size 10'em, 2'em
            label fmt"Increment"
            onClick: self.count.inc()
    
          ProgressBar:
            size 10'em, 2'em
            value: self.value

    gridTemplateDebugLines true

startFidget(
  drawMain,
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w=480, h=300
)
