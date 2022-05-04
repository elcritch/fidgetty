import std/strformat, std/hashes, std/sequtils

import fidgets
import fidgets/[button, dropdown, checkbox]
import fidgets/[slider, progressbar, animatedProgress]
import fidgets/[listbox]
import fidgets/[textinput]

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

proc exampleApp*(): ExampleApp {.appFidget.} =
  ## defines a stateful app widget
  properties:
    count1: int
    count2: int
    value: float
    myCheck: bool
    mySlider: float
    dropIndexes: int = -1
    textInput: string

  render:
    let currEvents = useEvents()
    let dropItems = @["Nim", "UI", "in", "100%", "Nim", "to",
                      "OpenGL", "Immediate", "mode"]

    setTitle(fmt"Fidget Animated Progress Example")
    textStyle theme
    fill "#F7F7F9"

    widget button:
      text: "Dump"
      setup:
        fill "#DFDFF0"
      onClick:
        echo "dump: "
        dumpTree(root)

    group "center":
      box 50, 0, 100'vw - 100, 100'vh
      orgBox 50, 0, 100'vw, 100'vw
      fill "#DFDFE0"
      strokeWeight 1

      self.value = (self.count1.toFloat * 0.10) mod 1.0
      var delta = 0.0

      vertical:
        blank: size(0, 0)
        itemSpacing 1.5'em

        vertical:
          itemSpacing 1.5'em
          # Trigger an animation on animatedProgress below
          widget button:
            text: fmt"Arg Incr {self.count1:4d}"
            onClick:
              self.count1.inc()
              delta = 0.02

          horizontal:
            itemSpacing 4'em

            widget button:
              text: fmt"Evt Incr {self.count2:4d}"
              onClick:
                self.count2.inc()
                currEvents["pbc1"] = IncrementBar(increment = 0.02)

            widget checkbox:
              value: self.myCheck
              text: fmt"Click {self.myCheck}"

        let ap1 = widget animatedProgress:
          delta: delta
          setup:
            bindEvents "pbc1", currEvents
            width 100'pw - 8'em

        horizontal:
          widget button:
            text: fmt"Animate"
            onClick:
              self.count2.inc()
              currEvents["pbc1"] = JumpToValue(target = 0.01)

          widget button:
            text: fmt"Cancel"
            onClick:
              currEvents["pbc1"] = CancelJump()

          widget dropdown:
            items: dropItems
            selected: self.dropIndexes
            label: "Menu"
            setup:
              size 12'em, 2'em

        text "data":
          size 60'vw, 2'em
          fill "#000000"
          # characters: fmt"AnimatedProgress value: {ap1.value:>6.2f}"
          characters: fmt"selected: {self.dropIndexes}"

        widget slider:
          value: ap1.value
          setup:
            size 60'vw, 2'em

        widget listbox:
          items: dropItems
          selected: self.dropIndexes
          itemsVisible: 4
          setup:
            size 60'vw, 2'em

        widget textInput:
          value: self.textInput
          setup:
            size 60'vw, 2'em

        widget button:
          text: fmt"{self.textInput}"
          disabled: true
          setup:
            size 60'vw, 2'em




startFidget(
  wrapApp(exampleApp, ExampleApp),
  theme = grayTheme,
  w = 640,
  h = 700,
  uiScale = 2.0
)
