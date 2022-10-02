
import std/[math, strformat]

import fidgetty
import fidgetty/themes
import fidgetty/[button, progressbar]
import fidgetty/[splitview]
import fidgetty/behaviors/dragger

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
    pos: float
    dragger: Dragger

proc new*(_: typedesc[GridApp]): GridApp =
  new result
  result.pos = 0.33

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

    SplitView:
      cornerRadius 0.5'em

      SplitBar:
        draggable true
        stroke theme.outerStroke
        imageOf theme.gloss
        fill palette.foreground
      
      rectangle "gutter":
        cornerRadius 0.2'em
        gridRow "main" // span "main"
        gridColumn "menu"

        fill rgba(66, 177, 44, 167).to(Color).spin(75.0)

        Vertical:
          itemSpacing 1'em
          size 100'pp, 100'pp

          Button:
            size 100'pp, 2'em
            label fmt"Button2: {parent.screenbox.w.float:6.0f}"
            onClick: self.count.inc()

          Button:
            size 100'pp, 2'em
            label fmt"Button2: {self.barVal.float:4.2f}"
            onClick: self.count.inc()
    
      rectangle "area":
        fill rgba(66, 177, 44, 167).to(Color).spin(100.0) * 0.2
        gridArea "main", "area"

        Vertical:
          self.value = (self.count.toFloat * 0.10) mod 1.0001

          ProgressBar:
            size 10'em, 2'em
            value: self.value


    # gridTemplateDebugLines true

startFidget(
  drawMain,
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w=480, h=300
)
