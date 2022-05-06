# Fidgetty

Widget library built on [Fidget](git@github.com:elcritch/fidget.git) written in pure Nim and OpenGL rendered.

![Demo](https://i.postimg.cc/ydxbyjJ4/Kapture-2022-05-04-at-01-07-14.gif)

Example application: 

```nim
proc exampleApp*(
    myName {.property: name.}: string,
): ExampleApp {.appFidget.} =
  ## defines a stateful app widget
  ## 
  ## `exampleApp` will be transformed to also take the basic
  ## widget parameters:
  ##  - self: ExampleApp
  ##  - setup: proc()
  ##  - post: proc()
  ## 
  ## These parameters support using the widget with the properties
  ## syntax. See the `button` examples below. The property name is
  ## either the argument name or can be set using the `property` pragma
  ## like show with `myName` that will provide a property of `name`.
  ## 
  
  properties:
    ## this creates a new ref object type name using the
    ## capitalized proc name which is `ExampleApp` in this example. 
    ## This will be customizable in the future. 
    count: int
    value: float

  render:
    setTitle(fmt"Fidget Animated Progress Example - {myName}")
    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
    fill "#F7F7F9"

    group "center":
      box 50, 0, 100.Vw - 100, 100.Vh
      orgBox 50, 0, 100.Vw, 100.Vw
      fill "#DFDFE0"
      strokeWeight 1

      self.value = (self.count.toFloat * 0.10) mod 1.0001
      progressbar(self.value, fmt"Progress: {self.value:4.2}") do:
        box 10.WPerc, 20, 80.WPerc, 2.Em

      horizontal:
        # creates an horizontal spacing box

        box 90.WPerc - 16.Em, 100, 8.Em, 2.Em
        itemSpacing 0.Em

        # Click to make the bar increase
        # basic syntax just calling a proc
        if button(fmt"Clicked1: {self.count:4d}"):
          self.count.inc()

        # Alternate format using `Widget` macro that enables
        # a YAML like syntax using property labels
        # (see parameters on `button` widget proc)
        widget button:
          text: fmt"Clicked2: {self.count:4d}"
          onClick: self.count.inc()

        # current limit on Widget macros is that all args
        # must be called as properties, no mix and match
        #
        # i.e. this doesn't work (yet):
        #     Widget button(fmt"Clicked2: {self.count:4d}"):
        #       onClick: self.count.inc()

      vertical:
        # creates a vertical spacing box

        box 10.WPerc, 160, 8.Em, 2.Em
        itemSpacing 1.Em

        # Button:
        #   # default alias of `Widget button`
        #   # only created for non-stateful widgets
        #   text: fmt"Clicked3: {self.count:4d}"
        #   setup: size 8.Em, 2.Em
        #   onClick: self.count.inc()

        widget button:
          text: fmt"Clicked4: {self.count:4d}"
          setup: size 8.Em, 2.Em
          onClick: self.count.inc()

var state = ExampleApp(count: 2, value: 0.33)

const callform {.intdefine.} = 2

proc drawMain() =
  frame "main":
    # we call exampleApp with a pre-made state
    # the `statefulWidget` always takes a `self` paramter
    # that that widgets state reference 
    # alternatively:
    #   exampleApp("basic widgets", state)
    widget exampleApp:
      name: "basic widgets"
      self: state

startFidget(drawMain, w=640, h=400, uiScale=2.0)
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

