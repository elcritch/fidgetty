import asyncdispatch # This is what provides us with async and the dispatcher

import ../fidgetty
import timers
import progressbar

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

variants AnimatedEvents:
  IncrementBar(increment: float)
  JumpToValue(target: float)
  CancelJump

fidgetty AnimatedProgress:
  properties:
    delta: float32
    events: Events
    target: float
  state:
    value: float
    cancelTicks: bool
    ticks: Future[void] = emptyFuture() ##\
      ## Create an completed "empty" future

proc new*(_: typedesc[AnimatedProgressProps]): AnimatedProgressProps =
  new result

proc ticker(props: AnimatedProgressProps, self: AnimatedProgressState) {.async.} =
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

    self.value += props.target * (1+frame.skipped).toFloat
    self.value = clamp(self.value mod 1.0, 0, 1.0)

proc render*(
    props: AnimatedProgressProps,
    self: AnimatedProgressState
): Events =
  let events = props.events

  processEvents(AnimatedEvents):
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
      props.target = target

      if self.ticks.isNil or self.ticks.finished:
        echo "ticker..."
        self.ticks = ticker(props, self)

  self.value = self.value + props.delta

  progressbar(self.value, fmt"{self.value:4.2}") do:
    boxOf parent

