import std/strformat, std/hashes

import fidgetty

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

fidgetty ButtonEvt:
  properties:
    empty: void
  state:
    empty: void

proc new*(_: typedesc[ButtonEvtProps]): ButtonEvtProps =
  new result
  box 0, 0, 8.Em, 2.Em

proc render*(
    props: ButtonEvtProps,
    self: ButtonEvtState
): Events[All]=
  clipContent true
  onHover:
    themeExtra atom"hover"
  onHover:
    themeExtra atom"clicked"
  onClick:
    dispatchMouseEvents()

type
  AppState* = ref object
    count1: int

proc exampleApp*() =
  ## defines a stateful app widget
  frame "main":
    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
    let self = withState(AppState)

    ButtonEvt:
      id "button"
      themeExtra atom"button"
      offset 4'em, 4'em
      size 10'em, 2'em
      text "text":
        boxSizeOf parent
        characters "Click me!"
    do -> MouseEvent:
      evClick:
        echo "hi!"
        inc self.count1


startFidget(
  exampleApp,
  setup = 
    when defined(demoBulmaTheme): bulmaTheme
    else: grayTheme,
  w=640, h=400
)