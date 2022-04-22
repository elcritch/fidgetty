import std/strformat

import widgets

proc slider*(value: var float) {.basicFidget.} =
  ## Draw a progress bars 

  init:
    ## called before `setup` and used for setting defaults like
    ## the default box size
    box 0, 0, 100.WPerc, 2.Em

  render:

    box 260, 90, 250, 10
    onClick:
      pipDrag = true
    if pipDrag:
      pipPos = int(mouse.descaled(pos).x - current.descaled(screenBox).x)
      pipPos = clamp(pipPos, 1, 240)
      pipDrag = buttonDown[MOUSE_LEFT]
    rectangle "pip":
      box pipPos, 0, 10, 10
      fill "#72bdd0"
      cornerRadius 5
    rectangle "fill":
      box 0, 3, pipPos, 4
      fill "#70bdcf"
      cornerRadius 2
      strokeWeight 1
    rectangle "bg":
      box 0, 3, 250, 4
      fill "#c2e3eb"
      cornerRadius 2
      strokeWeight 1