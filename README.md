# Fidgetty

Widget library built using a fork of [Fidget](https://github.com/elcritch/fidget) written in pure Nim and OpenGL rendered.

Note: You *must* use the forked version of Fidget. You can do a `nimble install https://github.com/elcritch/fidget`. 

![Demo](https://i.postimg.cc/ydxbyjJ4/Kapture-2022-05-04-at-01-07-14.gif)

```sh
nimble install
nim c -r tests/testDemo.nim
```

Example application: 

```nim
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
            label: fmt"Arg Incr {self.count1:4d}"
            setup:
              onClickOutside:
                echo "incr clicked outside"
            onClick:
              self.count1.inc()
              delta = 0.02
          Horizontal:
            itemSpacing 4'em
            Button(label = &"Evt Incr {self.count2:4d}"):
              onClick:
                self.count2.inc()
                currEvents["pbc1"] = IncrementBar(increment = 0.02)
            Theme(warningPalette()):
              Checkbox(label = fmt"Click {self.myCheck}"):
                checked: self.myCheck

        let ap1 =
          AnimatedProgress:
            delta: delta
            setup:
              bindEvents "pbc1", currEvents
              width 100'pw - 8'em

        Horizontal:
          Button(label = "Animate"):
            onClick:
              self.count2.inc()
              currEvents["pbc1"] = JumpToValue(target = 0.01)
          Button(label = "Cancel"):
            onClick:
              currEvents["pbc1"] = CancelJump()
          Dropdown:
            items: dropItems
            selected: self.dropIndexes
            defaultLabel: "Menu"
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
          setup:
            size 60'vw, 2'em
            bindEvents "lstbx", currEvents
        Slider:
          value: self.scrollValue
          setup: size 60'vw, 2'em
          changed:
            currEvents["lstbx"] = ScrollTo(self.scrollValue)
        TextInputBind:
          value: self.textInput
          setup: size 60'vw, 2'em
        Button(label = &"{self.textInput}"):
          disabled: true
          setup: size 60'vw, 2'em
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
```

Example stateful widget: 

```nim
proc animatedProgress*(
    delta: float32 = 0.1,
  ): AnimatedProgressState {.statefulFidget.} =

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

  onEvents(AnimatedEvents):
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

      proc ticker(self: AnimatedProgressState) {.async.} =
        ## This simple procedure will "tick" ten times delayed 1,000ms each.
        ## Every tick will increment the progress bar 10% until its done. 
        let duration = 3_000

        # await runEveryMillis(frameDelayMs, repeat=n) do (frame: FrameIdx) -> bool:
        await runForMillis(duration) do (frame: FrameIdx) -> bool:
          # echo "tick ", "frame ", frame, " ", inMilliseconds(getMonoTime() - start), "ms"
          refresh()
          if self.cancelTicks:
            self.cancelTicks = false
            return true

          self.value += target * (1+frame.skipped).toFloat
          self.value = clamp(self.value mod 1.0, 0, 1.0)
      
      if self.ticks.isNil or self.ticks.finished:
        echo "ticker..."
        self.ticks = ticker(self)

  
  render:
    self.value = self.value + delta

    progressbar(self.value, fmt"{self.value:4.2}") do:
      boxOf parent
```

