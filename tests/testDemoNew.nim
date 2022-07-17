import std/strformat, std/hashes, std/sequtils

import fidgetty
import fidgetty/themes
import fidgetty/[button, dropdown, checkbox]
import fidgetty/[slider, progressbar, animatedProgress]
import fidgetty/[listbox]
import fidgetty/[textinput]
import sugar

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

proc exampleApp*(): ExampleApp {.appFidget.} =
  ## defines a stateful app widget
  properties:
    count1: int
    count2: int
    value: float
    scrollValue: float
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
    fill palette.background.lighten(0.11)

    # font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter

    Vertical:
      ## Debugging button
      Button(label = "Dump"):
        proc setup() =
          fill "#DFDFF0"
        proc onClick() =
          echo "dump: "
          dumpTree(root)

    group "center":
      box 50, 0, 100'vw - 100, 100'vh
      orgBox 50, 0, 100'vw, 100'vw
      fill palette.background.darken(1'PP)
      strokeWeight 1

      self.value = (self.count1.toFloat * 0.10) mod 1.0
      var delta = 0.0
      Vertical:
        itemSpacing 1.5'em

        Vertical:
          itemSpacing 1.5'em

          # Trigger an animation on animatedProgress below
          Button:
            label = fmt"Arg Incr {self.count1:4d}"
            proc onClick() =
              self.count1.inc()
              delta = 0.02

          Horizontal:
            itemSpacing 4'em

            Button(label = &"Evt Incr {self.count2:4d}"):
              proc onClick() =
                self.count2.inc()
                currEvents["pbc1"] = IncrementBar(increment = 0.02)

            Theme(warningPalette()):
              Checkbox(label = fmt"Click {self.myCheck}"):
                checked = self.myCheck

        let ap1 =
          AnimatedProgress:
            delta = delta
            proc setup() =
              bindEvents "pbc1", currEvents
              width 100'pw - 8'em

        Horizontal:

          Button(label = "Animate"):
            proc onClick() =
              self.count2.inc()
              currEvents["pbc1"] = JumpToValue(target = 0.01)

          Button(label = "Cancel"):
            proc onClick() =
              currEvents["pbc1"] = CancelJump()

          Dropdown:
            items = dropItems
            selected = self.dropIndexes
            defaultLabel = "Menu"
            proc setup() =
              size 12'em, 2'em

        text "data":
          size 60'vw, 2'em
          fill "#000000"
          # characters: fmt"AnimatedProgress value: {ap1.value:>6.2f}"
          characters fmt"selected: {self.dropIndexes}"

        Slider:
          value = ap1.value
          setup = block:
            size 60'vw, 2'em
            size 60'vw, 2'em

        Listbox:
          items = dropItems
          selected = self.dropIndexes
          itemsVisible = 4
          proc setup() =
            size 60'vw, 2'em
            bindEvents "lstbx", currEvents

        Slider:
          value = self.scrollValue
          proc setup() =
            size 60'vw, 2'em
          proc changed() =
            currEvents["lstbx"] = ScrollTo(self.scrollValue)

        TextInputBind:
          value = self.textInput
          proc setup() =
            size 60'vw, 2'em

        Button(label = &"{self.textInput}"):
          disabled = true
          proc setup() =
            size 60'vw, 2'em

      palette.accent = parseHtml("#87E3FF", 0.67).spin(ap1.value * 36)

startFidget(
  wrapApp(exampleApp, ExampleApp),
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w = 640,
  h = 700,
  uiScale = 2.0
)
