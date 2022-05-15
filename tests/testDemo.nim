import std/strformat, std/hashes, std/sequtils

import fidgetty
import fidgetty/themes
import fidgetty/[button, dropdown, checkbox]
import fidgetty/[slider, progressbar, animatedProgress]
import fidgetty/[listbox]
import fidgetty/[textinput]

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
    fill palette.background.lighten(0.11)

    Button:
      text: "Dump"
      setup:
        fill "#DFDFF0"
      onClick:
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
        blank: size(0, 0)
        itemSpacing 1.5'em

        Vertical:
          itemSpacing 1.5'em
          # Trigger an animation on animatedProgress below
          Button:
            text: fmt"Arg Incr {self.count1:4d}"
            onClick:
              self.count1.inc()
              delta = 0.02
          Horizontal:
            itemSpacing 4'em
            Button:
              text: fmt"Evt Incr {self.count2:4d}"
              onClick:
                self.count2.inc()
                currEvents["pbc1"] = IncrementBar(increment = 0.02)
            Checkbox:
              value: self.myCheck
              text: fmt"Click {self.myCheck}"
              setup:
                # themeWith(fill = pallete.warning)
                var pl = palette
                pl.highlight = themePalette.warning.lighten(0.1)
                pl.foreground = themePalette.warning.lighten(0.2)
                pl.text = themePalette.textDark
                push pl
              post:
                pop(Palette)

        let ap1 = AnimatedProgress:
          delta: delta
          setup:
            bindEvents "pbc1", currEvents
            width 100'pw - 8'em

        Horizontal:
          Button:
            text: fmt"Animate"
            onClick:
              self.count2.inc()
              currEvents["pbc1"] = JumpToValue(target = 0.01)
          Button:
            text: fmt"Cancel"
            onClick:
              currEvents["pbc1"] = CancelJump()
          Dropdown:
            items: dropItems
            selected: self.dropIndexes
            label: "Menu"
            setup: size 12'em, 2'em

        text "data":
          size 60'vw, 2'em
          fill "#000000"
          # characters: fmt"AnimatedProgress value: {ap1.value:>6.2f}"
          characters: fmt"selected: {self.dropIndexes}"
        Slider:
          value: ap1.value
          setup: size 60'vw, 2'em
        Listbox:
          items: dropItems
          selected: self.dropIndexes
          itemsVisible: 4
          setup: size 60'vw, 2'em
        TextInputBind:
          value: self.textInput
          setup: size 60'vw, 2'em
        Button:
          text: fmt"{self.textInput}"
          disabled: true
          setup: size 60'vw, 2'em

startFidget(
  wrapApp(exampleApp, ExampleApp),
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w = 640,
  h = 700,
  uiScale = 2.0
)
