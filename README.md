# Fidgetty

Widget library built on [Fidget](git@github.com:elcritch/fidget.git) written in pure Nim and OpenGL rendered.

![Demo](https://i.postimg.cc/ydxbyjJ4/Kapture-2022-05-04-at-01-07-14.gif)

```sh
nimble install
nim c -r tests/testDemo.nim
```

Example application: 

```nim
import std/strformat, std/hashes, std/sequtils

import fidgetty
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
    fill "#F7F7F9"

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
      fill "#DFDFE0"
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
            setup:
              size 12'em, 2'em

        text "data":
          size 60'vw, 2'em
          fill "#000000"
          # characters: fmt"AnimatedProgress value: {ap1.value:>6.2f}"
          characters: fmt"selected: {self.dropIndexes}"

        Slider:
          value: ap1.value
          setup:
            size 60'vw, 2'em

        Listbox:
          items: dropItems
          selected: self.dropIndexes
          itemsVisible: 4
          setup:
            size 60'vw, 2'em

        TextInputBind:
          value: self.textInput
          setup:
            size 60'vw, 2'em

        Button:
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
```

Example stateful widget: 

```nim
proc animatedProgress*(
    delta: float32 = 0.1,
  ): AnimatedProgress {.statefulFidget.} =

  init:
    box 0, 0, 100.WPerc, 2.Em

  properties:
    value: float
    cancelTicks: bool
    ticks: Future[void] = emptyFuture() ##\
      ## Create an completed "empty" future
  
  events(AnimatedEvents):
    IncrementBar(increment: float)
    JumpToValue(target: float)
    CancelJump

  onEvents:
    IncrementBar(increment):
      # echo "pbar event: ", evt.repr()
      self.value = self.value + increment
      refresh()
    CancelJump():
      echo "cancel jump "
      self.cancelTicks = true and
                          not self.ticks.isNil and
                          not self.ticks.finished
    JumpToValue(target):
      echo "jump where? ", $target

      proc ticker(self: AnimatedProgress) {.async.} =
        ## This simple procedure will "tick" ten times delayed 1,000ms each.
        ## Every tick will increment the progress bar 10% until its done. 
        let
          frameDelay = 16
          duration = 3_000
          n = duration div frameDelay
        for i in 1..n:
          await sleepAsync(frameDelay)
          if self.cancelTicks:
            self.cancelTicks = false
            return
          self.value += target
          self.value = clamp(self.value mod 1.0, 0, 1.0)

          refresh()
      
      if self.ticks.isNil or self.ticks.finished:
        echo "ticker..."
        self.ticks = ticker(self)

  
  render:
    self.value = self.value + delta

    progressbar(self.value, fmt"{self.value:4.2}") do:
      boxOf parent
```

