import std/strformat

import widgets

proc slider*(
    value {.property: value.}: var float,
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
      sb = 0.3'em
      bwOrig = current.box().w
      bh = current.box().h
      bw = current.box().w - bh/2 - 2*sb

    onClick:
      self.pipDrag = true
    if self.pipDrag:
      value = (mouse.descaled(pos).x - current.descaled(screenBox).x)/bw
      value = clamp(value, 0'f32, 1.0'f32)
      self.pipDrag = buttonDown[MOUSE_LEFT]

    let
      wcalc = bw * float(value) + 0.001
      pipPos = wcalc.clamp(0.0, bw)
      wcalcBtn = (bw-sb) * float(value) + 0.001
      pipPosBtn = wcalcBtn.clamp(0.0, bw)
      # barH = bh - sb*sw

    rectangle "pip":
      # box pipPos-(bh/2-sb)/2+2*sb, sb, bh-2*sb, bh-2*sb
      box pipPosBtn+sb, sb, bh-2*sb, bh-2*sb
      fill "#72bdd0"
      cornerRadius theme
      strokeLine theme
    rectangle "fill":
      box sb, sb, pipPos+bh/2, bh-2*sb
      fill "#70bdcf"
      cornerRadius theme
    rectangle "bg":
      box 0, 0, bwOrig, bh
      fill "#c2e3eb"
      cornerRadius theme
      strokeLine theme