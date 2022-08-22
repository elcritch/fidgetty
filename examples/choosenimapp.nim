import std/strformat, std/hashes, std/sequtils

import fidgetty
import fidgetty/themes
import fidgetty/[button, dropdown, checkbox]
import fidgetty/[slider, progressbar, animatedProgress]
import fidgetty/[listbox]
import fidgetty/[textinput]

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

const blackBG = rgba(23, 24, 31, 255).color
const darkBG = rgba(32,33,44,255).color.lighten(0.01)
const textBG = rgba(27,29,38,255).color
const textFG = whiteColor
const headerFC = rgba(194,166,9,255).color
const regularFC = rgba(207,185,69, 255).color

proc chooseNimApp*(): ChooseNimApp {.appFidget.} =
  ## defines a stateful app widget
  properties:
    count1: int
    count2: int
    output: string

  render:
    proc doInstallNim(self: ChooseNimApp) =
      let msg = "Installing Nim..."
      self.output = msg

    proc doShow(self: ChooseNimApp) =
      let msg = "Show Nim..."
      self.output = msg

    let currEvents = useEvents()

    setTitle(fmt"Fidget Animated Progress Example")
    textStyle theme
    fill palette.background
    strokeWeight 1

    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter

    frame "autoLayout":
      # setup frame for css grid
      setWindowBounds(vec2(440, 460), vec2(1200, 800))
      centeredXY 98'pw, 98'ph
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
                        ["footer"] 100'ui \
                        ["bottom"]

      # draw debug lines
      # gridTemplateDebugLines true

      Theme(infoPalette({txtHighlight, bgDarken})):
        rectangle "banner":
          fill palette.background
          cornerRadius 1'em
          gridColumn "outer-l" // "outer-r"
          gridRow "top" // "middle"
          text "header":
            font "IBM Plex Sans", 32, 200, 0, hCenter, vCenter
            paddingXY 1'em, 1'em
            fill palette.text
            characters "Choose Nim!"
            textAutoResize tsHeight

      rectangle "footer":
        fill palette.background.lighten(0.03)
        cornerRadius 1'em
        gridColumn "outer-l" // "outer-r"
        gridRow "footer" // "bottom"

        text "footer-txt":
          font "IBM Plex Sans", 12, 200, 0, hCenter, vCenter
          paddingXY 1'em, 1'em
          fill palette.text
          characters self.output
          textAutoResize tsHeight

      rectangle "css grid item":
        # Setup CSS Grid Template
        cornerRadius 1'em
        gridColumn "outer-l" // "outer-r"
        gridRow "middle" // "footer"
        # some color stuff
        fill textBG

        frame "options":
          font "IBM Plex Sans", 16, 200, 40, hCenter, vCenter
          centeredXY 90'pw, 90'ph
          gridTemplateColumns 1'fr 3'fr 250'ui 3'fr 1'fr
          gridTemplateRows 100'ui 1'fr 40'ui 1'fr 40'ui 1'fr 40'ui 1'fr 40'ui 1'fr
          # gridTemplateDebugLines true
          text "info":
            height 6'em
            gridColumn 2 // 5
            gridRow 1 // 2
            fill palette.text
            characters """
            ChooseNimApp installs the Nim programming language from official downloads and sources, enabling you to easily switch between stable and development compilers.
            """

          font "IBM Plex Sans", 22, 200, 40, hCenter, vCenter

          Button:
            label: fmt"Install Nim"
            onClick:
              self.doInstallNim()
            setup:
              gridColumn 3 // 4
              gridRow 3 // 4
              size 250'ui, 40'ui

          Button:
            label: fmt"Show Nim Version"
            onClick:
              self.doShow()
            setup:
              gridColumn 3 // 4
              gridRow 5 // 6
              size 250'ui, 40'ui


startFidget(
  wrapApp(chooseNimApp, ChooseNimApp),
  setup = 
    setup(darkNimTheme),
  w = 640,
  h = 700,
  uiScale = 2.0
)