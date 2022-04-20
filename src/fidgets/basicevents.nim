
import bumpy, fidget, math, random
import std/strformat, std/hashes
import asyncdispatch # This is what provides us with async and the dispatcher
import times, strutils # This is to provide the timing output
import tables
import variant
import patty

import button
import progressbar

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

var
  frameCount = 0

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
      self.cancelTicks = true
    JumpToValue(target):
      echo "jump where? ", $target

      proc ticker(self: AnimatedProgress) {.async.} =
        ## This simple procedure will "tick" ten times delayed 1,000ms each.
        ## Every tick will increment the progress bar 10% until its done. 
        let
          n = 70
          duration = 2*600
          curr = self.value
        for i in 1..n:
          await sleepAsync(duration / n)
          if self.cancelTicks:
            self.cancelTicks = false
            return
          self.value += 0.01
          refresh()
      
      if self.ticks.isNil or self.ticks.finished:
        echo "ticker..."
        self.ticks = ticker(self)

  
  render:
    self.value = self.value + delta

    group "anim":
      boxOf parent
      progressbar(self.value) do:
        boxOf parent

    self.value = self.value mod 1.0


proc exampleApp*(
    myName {.property: name.}: string,
) {.appFidget.} =
  ## defines a stateful app widget
  
  properties:
    count1: int
    count2: int
    value: UnitRange

  render:
    # echo "events"
    let currEvents = useEvents()

    frame "main":
      setTitle(fmt"Fidget Animated Progress Example")
      font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
      fill "#F7F7F9"
      # echo fmt"main-main: {current.box()=}"

      group "center":
        box 50, 0, 100.Vw - 100, 100.Vh
        orgBox 50, 0, 100.Vw, 100.Vw
        fill "#DFDFE0"
        strokeWeight 1

        self.value = (self.count1.toFloat * 0.10) mod 1.0
        var delta = 0.0

        Vertical:
          # Trigger an animation on animatedProgress below
          Widget button:
            text: fmt"Arg Incr {self.count1:4d}"
            onClick:
              self.count1.inc()
              delta = 0.02

          Widget button:
            text: fmt"Incr {self.count2:4d}"
            onClick:
              self.count2.inc()
              currEvents["pbc1"] = IncrementBar(increment = 0.02)
        
    let ap1 = Widget animatedProgress:
      delta: delta
      setup:
        bindEvents "pbc1", currEvents
        box 0'em, 0'em, 14'em, 2.Em
    # echo "state: ap1: ", repr(ap1)
    
    Horizontal:
Widget button:
text: fmt"Animate"
onClick:
  self.count2.inc()
  currEvents["pbc1"] = JumpToValue(target = 0.02)

            Widget button:
              text: fmt"Cancel"
              onClick:
                self.count1.inc()
                currEvents["pbc1"] = CancelJump()

    text "data":
      size 90'vw, 2'em
      fill "#000000"
      characters: "AnimatedProgress value: " & repr(ap1.value)
  


var state = ExampleApp(count1: 0, count2: 0, value: 0.33)

proc drawMain() =
  # frameCount.inc
  # echo "\n" & fmt"drawMain: {frameCount=} "
  frame "main":
    exampleApp("basic widgets", state)


startFidget(drawMain, uiScale=2.0)
