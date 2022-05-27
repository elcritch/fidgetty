import std/strformat

import widgets

proc slider*(
    value {.property: value.}: var float,
    label {.property: label.} = "",
    clicker {.property: onChange.}: WidgetProc = proc () = discard,
    disabled {.property: disabled.}: bool = false
): SliderState {.statefulFidget.} =
  ## Draw a progress bars 

  init:
    box 0, 0, 100.WPerc, 2.Em
    textAutoResize tsHeight
    layoutAlign laStretch
    cornerRadius theme

  properties:
    pipDrag: bool
  
  render:
    let
      # some basic calcs
      sb = 0.3'em
      sbb = 2*sb
      barOuter = 0.5'em
      bh = current.box().h
      bw = current.box().w
      bww = bw - bh

    onClick:
      self.pipDrag = true

    var oldValue = value
    if self.pipDrag:
      let mpx = mouse.descaled(pos).x
      let sbx = current.descaled(screenBox).x
      value = ((mpx - sbx - bh/2)/bww).clamp(0'f32, 1.0'f32)
      self.pipDrag = buttonDown[MOUSE_LEFT]
      if oldValue != value:
        if not clicker.isNil:
          clicker()

    let
      pipPos = bww*clamp(value, 0, 1.0)

    text "text":
      box 0, 0, bw, bh
      fill palette.text
      characters label
    rectangle "pip":
      box sb+pipPos, sb, bh-2*sb, bh-2*sb
      fill palette.cursor
      cornerRadius theme
      stroke theme.outerStroke
      clipContent true
      imageOf theme.gloss
    rectangle "fg-bar":
      box barOuter, barOuter, pipPos+bh/2, bh-2*barOuter 
      fill palette.accent
      cornerRadius theme
      clipContent true
      imageOf theme.gloss, 0.77
    rectangle "bg":
      imageOf theme.gloss
      rotation 180
      box 0, 0, bw, bh
      fill palette.foreground
      cornerRadius theme
      clipContent true
      stroke theme.outerStroke