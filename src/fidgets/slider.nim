import std/strformat

import widgets

proc slider*(
    value {.property: value.}: var float,
    label {.property: label.} = ""
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
      sb = 0.4'em
      sbb = 2*sb
      barOuter = 0.6'em
      bh = current.box().h
      bw = current.box().w
      bww = bw - bh

    onClick:
      self.pipDrag = true

    if self.pipDrag:
      value = 1/bww*(mouse.descaled(pos).x - current.descaled(screenBox).x - bh/2)
      value = clamp(value, 0'f32, 1.0'f32)
      self.pipDrag = buttonDown[MOUSE_LEFT]

    let
      pipPos = bww*float(value)
      pipWidth = (bww)*float(value) + bh - sbb

    text "text":
      box 0, 0, bw, bh
      fill theme.textFill
      characters label
    rectangle "pip":
      box sb+pipPos, sb, bh-2*sb, bh-2*sb
      fill theme.cursor
      cornerRadius theme
      stroke theme.outerStroke
    rectangle "fg-bar":
      box sbb-barOuter/2, barOuter, pipPos+sb, bh-2*barOuter 
      fill theme.foreground
      cornerRadius theme
    rectangle "bg":
      box 0, 0, bw, bh
      fill theme.fill
      cornerRadius theme
      stroke theme.outerStroke