import std/strformat

import widgets

proc slider*(
    value {.property: value.}: var float,
    label {.property: label.} = ""
): SliderState {.statefulFidget.} =
  ## Draw a progress bars 

  init:
    ## called before `setup` and used for setting defaults like
    ## the default box size
    box 0, 0, 100.WPerc, 2.Em

  properties:
    pipDrag: bool
  
  render:
    let
      # some basic calcs
      sb = 0.4'em
      sbb = 2*sb
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
      fill "#565555"
      characters fmt"value: {value:4.2}"
    rectangle "pip":
      box sb+pipPos, sb, bh-2*sb, bh-2*sb
      fill "#72bdd0"
      cornerRadius theme
      strokeLine theme
    rectangle "fill":
      box sb, sb, pipWidth, bh-2*sb
      fill "#70bdcf"
      cornerRadius theme
    rectangle "bg":
      box 0, 0, bw, bh
      fill "#c2e3eb"
      cornerRadius theme
      strokeLine theme