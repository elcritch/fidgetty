import std/strformat, std/hashes

import fidgetty
import fidgetty/[button, progressbar, animatedProgress]

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

proc exampleApp*(
    myName : string,
) {.appFidget.} =
  ## defines a stateful app widget
  
  properties:
    count1: int
    count2: int
    value: float32

  render:
    let currEvents = useEvents()

    setTitle(fmt"Fidget Animated Progress Example")
    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
    fill "#F7F7F9"

    group "center":
      box 50, 0, 100'vw - 100, 100'vh
      orgBox 50, 0, 100'vw, 100'vw
      fill "#DFDFE0"
      strokeWeight 1

      self.value = (self.count1.toFloat * 0.10) mod 1.0
      var delta = 0.0

      Vertical:
        blank: size(0,0)
        itemSpacing 1.5'em

        Vertical:
          itemSpacing 1.5'em
          # Trigger an animation on animatedProgress below
          Button:
            label: fmt"Arg Incr {self.count1:4d}"
            disabled: true
            onClick:
              self.count1.inc()
              delta = 0.02

          Button:
            label: fmt"Evt Incr {self.count2:4d}"
            onClick:
              self.count2.inc()
              currEvents["pbc1"] = IncrementBar(increment = 0.02)
      
        let ap1 = AnimatedProgress:
          delta: delta
          setup:
            bindEvents "pbc1", currEvents
            # width parent.box().w - 6'em
            width  100'pw - 8'em
            # box 0'em, 0'em, 18'em, 2.Em
        
        Horizontal:
          Button:
            label: fmt"Animate"
            onClick:
              self.count2.inc()
              currEvents["pbc1"] = JumpToValue(target = 0.02)

          Button:
            label: fmt"Cancel"
            onClick:
              currEvents["pbc1"] = CancelJump()

        text "data":
          size 60'vw, 2'em
          fill "#000000"
          characters: fmt"AnimatedProgress value: {ap1.value:>6.2f}"
        

var state = ExampleApp(count1: 0, count2: 0, value: 0.33)

proc drawMain() =
  frame "main":
    exampleApp("basic widgets", state)


startFidget(drawMain, theme=grayTheme, w=640, h=400, uiScale=2.0)