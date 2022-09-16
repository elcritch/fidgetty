import std/strformat, std/hashes, std/sequtils

import fidgetty
import fidgetty/themes
import fidgetty/[button, dropdown, checkbox]
import fidgetty/[progressbar, animatedProgress]
import fidgetty/[slider]
import fidgetty/[listbox]
# import fidgetty/[textinput]

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

fidgetty DemoApp:
  properties:
    count1: int
    count2: int
    value: float
    mySlider: float
    scrollValue: float
    myCheck: bool
    dropIndexes: int
    textInput: string
    evts: Events

var self = DemoAppProps.new()

proc testDemo() =
  ## defines a stateful app widget
  let dropItems = @["Nim", "UI", "in", "100%", "Nim", "to",
                    "OpenGL", "Immediate", "mode"]

  setTitle(fmt"Fidget Animated Progress Example")
  textStyle theme
  fill palette.background.lighten(0.11)

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
          size 10'em, 2'em
          label fmt"Arg Incr {self.count1:4d}"
          onClick:
            self.count1.inc()
            delta = 0.02
        
        Horizontal:
          itemSpacing 4'em
          Button:
            size 10'em, 2'em
            label fmt"Evt Incr {self.count2:4d}"
            onClick:
              self.count2.inc()
              self.evts.add IncrementBar(increment = 0.02)
              refresh()
          Theme(warningPalette()):
            Checkbox:
              size 10'em, 2'em
              label fmt"Click {self.myCheck}"
              checked self.myCheck
              onClick:
                self.myCheck = not self.myCheck

      AnimatedProgress:
        delta 0.02
        triggers self.evts
        size 100.WPerc - 8'em, 2.Em

      Horizontal:
        itemSpacing 0.5'em

        Button:
          size 6'em, 2'em
          label "Animate"
          onClick:
            self.count2.inc()
            self.evts.add JumpToValue(target = 0.01)
            refresh()
        
        Button:
          size 6'em, 2'em
          label "Cancel"
          onClick:
            self.evts.add CancelJump()
            refresh()
        
        Dropdown:
          size 12'em, 2'em
          items dropItems
          selected self.dropIndexes
          defaultLabel "Menu"
        do -> ValueChange:
          Index(idx):
            self.dropIndexes = idx
            refresh()

      text "data":
        size 60'vw, 2'em
        fill "#000000"
        characters: fmt"selected: {self.dropIndexes}"
      
      Slider:
        size 60'vw, 2'em
        value self.mySlider
      do -> ValueChange:
        Float(val):
          self.mySlider = val
          refresh()
      
      Listbox:
        items dropItems
        selected self.dropIndexes
        itemsVisible 4
        triggers self.evts
        size 60'vw, 2'em
      do -> ValueChange:
        Index(val):
          self.dropIndexes = val
          refresh()
      
      Slider:
        value self.scrollValue
        size 60'vw, 2'em
      do -> ValueChange:
        Float(val):
          self.evts.add ScrollTo(val)
          self.scrollValue = val
          refresh()
      
      # TextInputBind:
      #   value: self.textInput
      #   setup: size 60'vw, 2'em

      Button:
        label &"{self.textInput}"
        disabled true
        size 60'vw, 2'em

startFidget(
  testDemo,
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w = 640,
  h = 700,
  uiScale = 2.0
)
