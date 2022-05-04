import fidgets
import fidgets/dropdown
  
let dropItems = @["Nim", "UI", "in", "100%", "Nim", "to", 
                  "OpenGL", "Immediate", "mode"]
var dropIndexes = [-1, -1, -1]

var dstate = DropdownState()

proc drawMain() =
  frame "main":
    font "IBM Plex Sans", 16, 200, 0, hLeft, vBottom
    box 1'em, 1'em, 100'pw - 1'em, 100'ph - 1'em

    vertical:
      itemSpacing 1'em

      text "first desc":
        size 100'pw, 1'em
        fill "#000d00"
        characters "Dropdown example: "

      dropdown(dropItems, dropIndexes[0], dstate)
      dropdown(dropItems, dropIndexes[1], nil)
      text "desc":
        size 100'pw, 1'em
        fill "#000d00"
        characters "linked dropdowns: "
      dropdown(dropItems, dropIndexes[2])
      widget dropdown:
        items: dropItems
        dropSelected: dropIndexes[2]
        setup: box 0, 0, 12'em, 2'em
      

startFidget(drawMain, uiScale=2.0, w=600, h=300)