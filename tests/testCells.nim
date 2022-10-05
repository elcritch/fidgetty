import fidgetty
import fidgetty/textinput
import re

setTitle("Auto Layout Vertical")

import print
const hasGaps = false

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

type
  AppState = ref object
    ## this creates a new ref object type name using the
    ## capitalized proc name which is `ExampleApp` in this example. 
    ## This will be customizable in the future. 
    rows: int
    cols: int
    textInput: seq[string]

proc new*(_: typedesc[AppState]): AppState =
  new result
  result.cols = 5
  result.rows = 3
  result.textInput = newSeq[string](result.cols * result.rows)

proc drawMain() =
  frame "autoLayout":
    useState[AppState](self)

    font "IBM Plex Sans", 16, 400, 16, hLeft, vCenter
    box 0, 0, 100'vw, 100'vh
    fill rgb(224, 239, 255).to(Color)

    frame "css grid area":
      # if current.gridTemplate != nil:
      #   echo "grid template: ", repr current.gridTemplate
      # setup frame for css grid
      box 10'pp, 10'pp, 80'pp, 80'pp
      fill "#FFFFFF"
      cornerRadius 0.5'em
      clipContent true
      rowGap 1'ui
      columnGap 1'ui
      
      # Setup CSS Grid Template
      let cw = 6'em
      let ch = 2'em
      gridTemplateColumns csFixed(cw) csFixed(cw) csFixed(cw) csFixed(cw) csFixed(cw) 
      gridTemplateRows csFixed(ch) csFixed(ch) csFixed(ch) 
      justifyContent CxCenter

      theme().outerStroke = Stroke.init(2, "#707070", 1.0)

      for i in 0..<self.cols * self.rows:
          TextInput:
            # theme.
            textAlign hCenter, vCenter
            cornerRadius 2
            value self.textInput[i]
            pattern re"[0-9\.]"
            # fill rgba(66, 177, 44, 167).to(Color).spin(i.toFloat*20+50)

            rectangle "overlay":
              if state.editing:
                stroke palette.highlight * 0.80
                strokeWeight 0.5'em
              if item.isActive:
                highlight palette
          do -> ChangeEvent[string]:
            Changed(val):
              self.textInput[i] = val
              refresh()
            

      # draw debug lines
      # gridTemplateDebugLines true
      

startFidget(drawMain, setup = setup(grayTheme), w = 640, h = 400)
