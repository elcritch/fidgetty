import asyncdispatch # This is what provides us with async and the dispatcher

import ../fidgetty
import progressbar

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

import std/monotimes, std/times

var
  frameCount = 0

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
        let
          frameDelay = 16
          duration = 3_000
          n = duration div frameDelay
        var prev = getMonoTime()
        for i in 1..n:
          await sleepAsync(frameDelay)
          if self.cancelTicks:
            self.cancelTicks = false
            return
          self.value += target
          self.value = clamp(self.value mod 1.0, 0, 1.0)
          let ts = getMonoTime()
          let dt = inMilliseconds(ts-prev)
          if dt >= frameDelay + frameDelay div 2:
            prev = ts
            continue
          prev = ts
          refresh()
      
      if self.ticks.isNil or self.ticks.finished:
        echo "ticker..."
        self.ticks = ticker(self)

  
  render:
    self.value = self.value + delta

    progressbar(self.value, fmt"{self.value:4.2}") do:
      boxOf parent

