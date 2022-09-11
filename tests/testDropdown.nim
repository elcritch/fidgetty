import fidgetty
import fidgetty/dropdown
  
let dropItems = @["Nim", "UI", "in", "100%", "Nim", "to", 
                  "OpenGL", "Immediate", "mode"]
var dropIndexes = [-1, -1, -1]

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")
var dstate = DropdownState()

proc drawMain() =
  frame "main":
    font "IBM Plex Sans", 14, 200, 0, hCenter, vCenter
    box 1'em, 1'em, 100'pw - 1'em, 100'ph - 1'em

    Vertical:
      itemSpacing 1'em

      text "first desc":
        size 100'pw, 1'em
        fill "#000d00"
        characters "Dropdown example: "

      dropdown(dropItems, dropIndexes[0], "Dropdown", self = dstate)
      dropdown(dropItems, dropIndexes[1], "Dropdown", self = nil)
      text "desc":
        size 100'pw, 1'em
        fill "#000d00"
        characters "linked dropdowns: "
      dropdown(dropItems, dropIndexes[2])
      Dropdown:
        items: dropItems
        selected: dropIndexes[2]
        setup:
          box 0, 0, 12'em, 2'em
      

startFidget(
  drawMain,
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w = 640,
  h = 700,
  uiScale = 2.0
)
