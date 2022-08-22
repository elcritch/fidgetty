import std/strformat, std/hashes, std/sequtils, std/strutils, std/sequtils
import std/asyncdispatch # This is what provides us with async and the dispatcher

import fidgetty
import fidgetty/timers
import fidgetty/themes
import fidgetty/[button, dropdown, checkbox]
import fidgetty/[slider, progressbar, animatedProgress]
import fidgetty/[listbox]
import fidgetty/[textinput]

import asynctools

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

const blackBG = rgba(23, 24, 31, 255).color
const darkBG = rgba(32,33,44,255).color.lighten(0.01)
const textBG = rgba(27,29,38,255).color
const textFG = whiteColor
const headerFC = rgba(194,166,9,255).color
const regularFC = rgba(207,185,69, 255).color

proc log(output: var seq[string], msg: string) =
  output.add(msg)
  if output.len() > 5:
    output = output[^5..^1]

proc chooseNimApp*(): ChooseNimApp {.appFidget.} =
  ## defines a stateful app widget
  properties:
    count1: int
    count2: int
    output: seq[string]
    versions: seq[string]
    versionSelected: int
    initialized: bool
    listPid: Future[void] = emptyFuture() ##\
      ## Create an completed "empty" future

  render:
    proc doInstallNim(self: ChooseNimApp) =
      let msg = "Installing Nim..."
      self.output.log msg

    proc doShow(self: ChooseNimApp) =
      let msg = "Show Nim..."
      self.output.log msg

    proc listVersions(self: ChooseNimApp) {.async.} =
      ## This simple procedure will "tick" ten times delayed 1,000ms each.
      ## Every tick will increment the progress bar 10% until its done. 
      echo "running..."
      # let (res, output) = await execProcess("choosenim", @["--noColors", ], options={})
      # let (res, output) = await execProcess("ls", @[], options={})
      let (res, output) = await execProcess("choosenim --noColor versions")
      echo "done..."
      self.output.add("done: " & $res)
      refresh()
      var avails = false
      for line in output.split("\n").mapIt(strutils.strip(it)):
        if avails and line.len() > 0:
          self.versions.add(line)
        if line == "Available:":
          avails = true

    # let currEvents = useEvents()
    if not self.initialized:
      self.initialized = true
      self.versionSelected = -1
      self.output.log "getting versions..."
      self.listPid = listVersions(self)

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
        clipContent true
        scrollBars true
        size 90'pw, 100'ui

        text "footer-txt":
          font "IBM Plex Sans", 12, 200, 22, hCenter, vCenter
          paddingXY 1'em, 1'em
          fill palette.text
          characters self.output.join("\n")
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
          gridTemplateRows 100'ui 2'fr 40'ui 1'fr 40'ui 1'fr 40'ui 1'fr 40'ui 1'fr 1'fr
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
            disabled: self.versionSelected < 0
            onClick:
              self.doInstallNim()
            setup:
              gridColumn 3 // 4
              gridRow 5 // 6
              size 250'ui, 40'ui

          Dropdown:
            items: self.versions
            defaultLabel: "Available Versions"
            selected: self.versionSelected
            setup:
              gridColumn 3 // 4
              gridRow 3 // 4
              size 250'ui, 40'ui


startFidget(
  wrapApp(chooseNimApp, ChooseNimApp),
  setup = 
    setup(darkNimTheme),
  w = 600,
  h = 700,
  uiScale = 2.0
)