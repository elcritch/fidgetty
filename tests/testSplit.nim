
import std/[math, strformat]

import fidgetty
import fidgetty/themes
import fidgetty/[button, progressbar]

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
    box 0, 0, 100'vw, 100'vh
    gridTemplateRows ["top"] csFixed(Em(1)) \
                      ["main"] 1'fr \
                      ["bottom"] csFixed(Em(1))
    
    gridTemplateColumns ["left"] csFixed(Em(1)) \
                      ["menu"] csFixed(10'em.float32 + self.barVal + self.barOffset) \
                      ["bar"] csFixed(0.5'em) \
                      ["area"] 2'fr \
                      ["right"] csFixed(Em(1))


    rectangle "border":
      cornerRadius 0.2'em
      gridRow "main"
      gridColumn "menu" // "right"
      stroke 0.1'em.float32, blackColor

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
  
    rectangle "bar":
      gridArea "main", "bar"

      fill rgba(66, 177, 44, 167).to(Color).spin(85.0)

      onClick:
        self.pipDrag = true
        self.pipPos = current.mouseRelativeStart()
        self.barVal = self.barVal + self.barOffset

      if self.pipDrag:
        self.pipDrag = buttonDown[MOUSE_LEFT]
        self.barOffset = self.pipPos.mouseRelativeDiff().x.float32

    rectangle "area":
      fill rgba(66, 177, 44, 167).to(Color).spin(100.0) * 0.2
      gridRow "main" // span "main"
      gridColumn "area" // span "area"

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
