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

const verExample = """
   Channel: stable

 Installed:  
          * 1.6.6 (latest)

 Available:  
            1.6.4
            1.6.2
            1.6.0
            1.4.8
            1.4.6
            1.4.4
            1.4.2
            1.4.0
            1.2.18
            1.2.16
            1.2.14
            1.2.12
            1.2.10
            1.2.8
            1.2.6
            1.2.4
            1.2.2
            1.2.0
            1.0.10
            1.0.8
            1.0.6
            1.0.4
            1.0.2
            1.0.0
            0.20.2
            0.20.0
            0.19.6
            0.19.4
            0.19.2



"""

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

proc log(output: var seq[string], msg: string) =
  const logCnt = 1000
  output.add(msg)
  if output.len() > logCnt:
    output = output[^logCnt..^1]

proc chooseNimApp*(): ChooseNimApp {.appFidget.} =
  ## defines a stateful app widget
  properties:
    count1: int
    count2: int
    output: seq[string]
    updateLines: int
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
      self.output.log "getting versions..."
      # let (res, output) = await execProcess("choosenim --noColor versions")
      await sleepAsync(1_111)
      let (res, output) = (0, verExample)
      var avails = false
      for line in output.split("\n").mapIt(strutils.strip(it)):
        if avails and line.len() > 0:
          self.versions.add(line)
          self.output.log(line)
        if line == "Available:":
          avails = true
      self.output.log "versions loaded..."
      self.updateLines = 1
      refresh()

    # let currEvents = useEvents()
    if not self.initialized:
      self.initialized = true
      self.versionSelected = -1
      self.output.log "getting versions..."
      self.listPid = listVersions(self)

    setTitle(fmt"Fidget Animated Progress Example")
    textStyle theme
    fill palette.background.lighten(0.02)
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
                        ["footer"] 200'ui \
                        ["bottom"]

      # draw debug lines
      # gridTemplateDebugLines true

      Theme(infoPalette({txtHighlight, bgDarken})):
        rectangle "banner":
          fill palette.background
          cornerRadius 1'em
          gridColumn "outer-l" // "outer-r"
          gridRow "top" // "middle"
          # echo "banner: box: ", current.box.repr
          text "header":
            font "IBM Plex Sans", 32, 200, 0, hCenter, vCenter
            paddingXY 1'em, 1'em
            fill palette.text
            characters "Choose Nim!"
            textAutoResize tsHeight

      frame "footer-box":
        font "IBM Plex Sans", 12, 200, 0, hCenter, vCenter
        gridColumn "outer-l" // "outer-r"
        gridRow "footer" // "bottom"
        size 80'vw, 200'ui
        # echo "footer-box: box: ", current.box.repr

        rectangle "footer":
          fill palette.background.lighten(0.03)
          cornerRadius 1'em
          clipContent true
          scrollBars true
          size 100'pw, self.output.len().UICoord * 22'ui
          # echo "footer: box: ", current.box.repr

          echo "footer: offset.y: ", $current.offset.y.float32
          if self.updateLines == 2:
            echo "footer: offset.y.new: ", $current.offset.y.float32
            current.offset.y =
              (current.screenBox.h - parent.screenBox.h) * 1.0.UICoord
            self.updateLines = 0
            refresh()

          text "footer-txt":
            paddingXY 1'em, 1'em
            fill palette.text
            textAutoResize tsHeight
            size 100'pw, self.output.len().UICoord * lineHeight().UICoord
            if self.updateLines == 1:
              echo "new footer text"
              self.updateLines = 2
              characters self.output.join("\n")
              refresh()
            # echo "footer-txt: box: ", current.box.repr

      rectangle "css grid item":
        # Setup CSS Grid Template
        cornerRadius 1'em
        gridColumn "outer-l" // "outer-r"
        gridRow "middle" // "footer"
        # some color stuff
        fill palette.background

        frame "options":
          centeredXY 90'pw, 90'ph
          gridTemplateColumns 1'fr 3'fr 250'ui 3'fr 1'fr
          gridTemplateRows 16'ui 4'fr 2'fr 40'ui 1'fr 40'ui 1'fr 40'ui 1'fr 1'fr
          # gridTemplateDebugLines true

          font "IBM Plex Sans", 22, 200, 0, hCenter, vCenter

          Dropdown:
            items: self.versions
            defaultLabel: "Available Versions"
            selected: self.versionSelected
            setup:
              gridColumn 3 // 4
              gridRow 4 // 5
              size 250'ui, 40'ui

          Button:
            label: fmt"Install Nim"
            disabled: self.versionSelected < 0
            onClick:
              self.doInstallNim()
            setup:
              gridColumn 3 // 4
              gridRow 6 // 7
              size 250'ui, 40'ui

          # make a textbox behind the above
          rectangle "button-bg":
            height 6'em
            gridColumn 2 // 5
            gridRow 3 // 10
            fill palette.background

          text "info":
            font "IBM Plex Sans", 14, 200, 0, hCenter, vCenter
            height 6'em
            gridColumn 2 // 5
            gridRow 2 // 3
            fill palette.text
            characters """
            ChooseNimApp installs the Nim programming language from official downloads and sources, enabling you to easily switch between stable and development compilers.
            """



startFidget(
  wrapApp(chooseNimApp, ChooseNimApp),
  setup = 
    setup(darkNimTheme),
  w = 800,
  h = 600,
  uiScale = 2.0
)