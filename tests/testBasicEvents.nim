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
): Events =
  clipContent true
  onHover:
    highlight palette
  onClick:
    highlight palette
  dispatchMouseEvents()

type
  AppState* = ref object
    count1: int

proc exampleApp*() =
  ## defines a stateful app widget
  frame "main":
    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
    let self = withState(AppState)
    let currEvents = useEvents()

    ButtonEvt:
      fill palette.foreground
      offset 4'em, 4'em
      size 10'em, 2'em
      text "button text":
        boxSizeOf parent
        fill palette.text
        characters "Click me!"
        textAutoResize tsHeight
    do -> MouseEvent:
      evClick:
        echo "hi!"
        inc self.count1


startFidget(
  exampleApp,
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w=640, h=400,
  uiScale=2.0
)