import std/strformat, std/hashes, std/sequtils

import fidgetty
import fidgetty/themes
import fidgetty/[button, dropdown, checkbox]
import fidgetty/[slider, progressbar, animatedProgress]
import fidgetty/[listbox]
import fidgetty/[textinput]

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

const blackBG = rgba(23, 24, 31, 255).color
const darkBG = rgba(32,33,44,255).color
const textBG = rgba(27,29,38,255).color
const headerFC = rgba(194,166,9,255).color
const regularFC = rgba(207,185,69, 255).color

proc chooseNimApp*(): ChooseNimApp {.appFidget.} =
  ## defines a stateful app widget
  properties:
    count1: int
    count2: int
    value: float
    scrollValue: float
    myCheck: bool
    mySlider: float
    dropIndexes: int = -1
    textInput: string

  render:
    let currEvents = useEvents()
    let dropItems = @["Nim", "UI", "in", "100%", "Nim", "to",
                      "OpenGL", "Immediate", "mode"]

    setTitle(fmt"Fidget Animated Progress Example")
    textStyle theme
    fill darkBG
    strokeWeight 1

    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter

    # text "header":
    #   size 10'em, 2'em
    #   fill "#ffffff"
    #   characters "Choose Nim!"
    #   textAutoResize tsHeight

    frame "autoLayout":
      # setup frame for css grid
      setWindowBounds(vec2(400, 200), vec2(1200, 800))
      centeredXY 90'pw, 90'ph
      fill clearColor
      cornerRadius 0.5'em
      # clipContent true
      
      # Setup CSS Grid Template
      gridTemplateColumns ["edge-l"]  40'ui \
                          ["outer-l"] 50'ui \
                          ["inner-l"] 1'fr \
                          ["inner-r"] 50'ui \
                          ["outer-r"] 40'ui \
                          ["edge-r"]

      gridTemplateRows  ["header"] 30'ui \
                        ["top"]    70'ui \
                        ["middle"] 1'fr \ 
                        ["footer"] 30'ui \
                        ["bottom"]

      rectangle "css grid item":
        # Setup CSS Grid Template
        
        cornerRadius 1'em
        gridColumn "outer-l" // "outer-r"
        gridRow "top" // "middle"
        fill blackBG
        text "header":
          font "IBM Plex Sans", 32, 200, 0, hCenter, vCenter
          paddingXY 1'em, 1'em
          fill headerFC
          characters "Choose Nim!"
          textAutoResize tsHeight

      rectangle "css grid item":
        # Setup CSS Grid Template
        font "IBM Plex Sans", 16, 200, 40, hCenter, vTop
        cornerRadius 1'em
        gridColumn "outer-l" // "outer-r"
        gridRow "middle" // "footer"
        # some color stuff
        fill textBG
        text "info":
          centeredXY 90'pw, 90'ph
          fill whiteColor
          characters """
          ChooseNimApp installs the Nim programming language from official downloads and sources, enabling you to easily switch between stable and development compilers.
          """

      # draw debug lines
      gridTemplateDebugLines true




startFidget(
  wrapApp(chooseNimApp, ChooseNimApp),
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w = 640,
  h = 700,
  uiScale = 2.0
)