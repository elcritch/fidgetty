
import bumpy, fidget, math, random
import std/strformat
import asyncdispatch # This is what provides us with async and the dispatcher
import times, strutils # This is to provide the timing output
import macros

import fidgets

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")


template dropUpY(n: Node, height: float32 = 0): bool =
  let a = n.descaled(screenBox)
  let b = root.descaled(screenBox)
  not (a.y + height <= b.y + b.h)

proc dropdown*(
    dropItems {.property: items.}: seq[string],
    dropSelected: var int,
) {.statefulFidget.} =
  ## dropdown widget with internal state using `useState`
  init:
    size 8'em, 1.5'em
  
  properties:
    dropDownOpen: bool
    dropUp: bool
    # dropDownToClose: bool

  render:
    var
      cb = current.box()
      bw = cb.w
      bh = cb.h
      # bh = 1.8.Em
      bth = bh
      bih = bh * 1.0 # 1.4.Em
      # bdh = 100.Vh - 3*bth
      bdh = min(bih * min(6, dropItems.len()).float32, windowLogicalSize.y/2)
      tw = bw - 1'em
    
    box cb.x, cb.y, bw, bh

    font "IBM Plex Sans", 12, 200, 0, hCenter, vCenter

    rectangle "button":
      cornerRadius 5
      strokeWeight 1
      size bw, bh
      fill "#72bdd0"
      dropShadow 3, 0, 0, "#000000", 0.03
      onHover:
        fill "#5C8F9C"
      onClick:
        self.dropDownOpen = true
        self.dropUp = current.dropUpY(bdh)

      text "text":
        box 0, 0, bw, bth
        fill "#ffffff"
        strokeWeight 1
        if dropSelected < 0:
          characters "Dropdown"
        else:
          characters dropItems[dropSelected]
      text "text":
        box tw, 0, 1'em, bth
        fill "#ffffff"
        if self.dropDownOpen:
          rotation -90
        else:
          rotation 0
        characters ">"

    let spad = 1.0'f32
    if self.dropDownOpen:
      group "dropDownScroller":
        if self.dropUp:
          box 0, bh-bdh-bth, bw, bdh
        else:
          box 0, bh, bw, bdh

        clipContent true
        zlevel ZLevelRaised
        cornerRadius 3
        # dropShadow 5, -3, -3, "#000000", 0.06

        group "dropDownOutside":
          box 0, 0, bw, bdh
          cornerRadius 3
          strokeLine spad, "#000000", 0.33

        group "dropDownOutside":
          fill "#82cde0"
          box 0, 0, bw, 6*spad
        group "dropDownOutside":
          fill "#82cde0"
          box 0, bdh-6*spad, bw, 6*spad

        group "dropDown":
          box spad, 6*spad, bw, bdh-6*spad
          # cornerRadius 3.3
          layout lmVertical
          counterAxisSizingMode csAuto
          horizontalPadding 0
          verticalPadding 0
          itemSpacing -1
          scrollBars true
          clipContent true

          onClickOutside:
            self.dropDownOpen = false
            self.dropUp = false

          for idx, buttonName in pairs(dropItems):
            group "itembtn":
              fill "#7CAFBC"
              box 0, 0, bw, 1.4*spad
            group "itembtn":
              box 0, 0, bw, bih
              layoutAlign laCenter
              fill "#72bdd0"
              # strokeLine 1.4, "#000000", 0.2
              text "text":
                box 0, 0, bw, bih
                fill "#ffffff"
                characters buttonName

              onHover:
                fill "#5C8F9C"
                self.dropDownOpen = true
              onClick:
                self.dropDownOpen = false
                echo "dropdown selected: ", buttonName
                dropSelected = idx
          group "itembtn":
            fill "#7CAFBC"
            box 0, 0, bw, 1.4*spad
          group "itempost":
            box 0, 0, bw, 12.5*spad

  
let dropItems = @["Nim", "UI", "in", "100%", "Nim", "to", 
                  "OpenGL", "Immediate", "mode"]
var dropIndexes = [-1, -1, -1]

var dstate = Dropdown()

proc drawMain() =
  frame "main":
    font "IBM Plex Sans", 16, 200, 0, hLeft, vBottom
    box 1'em, 1'em, 100'pw - 1'em, 100'ph - 1'em
    # offset 1'em, 1'em
    # size 100.WPerc - 1'em, 100.HPerc - 1'em

    Vertical:
      # strokeLine 1.0, "#46D15F", 1.0
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
      Widget dropdown:
        items: dropItems
        dropSelected: dropIndexes[2]
        setup: box 0, 0, 12'em, 2'em
      
    # dropdown(dropItems, dropIndexes[2], nil) do:
      # box 30, 80, 10.Em, 1.5.Em
    # dropdown(dropItems, dropIndexes[2], nil) do:
      # box 30, 120, 10.Em, 1.5.Em

startFidget(drawMain, uiScale=2.0, h=600)
