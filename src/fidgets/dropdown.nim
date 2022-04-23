
import bumpy, fidget, math, random
import std/strformat
import asyncdispatch # This is what provides us with async and the dispatcher
import times, strutils # This is to provide the timing output
import macros

import widgets

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

template dropUpY(n: Node, height: float32 = 0): bool =
  let a = n.descaled(screenBox)
  let b = root.descaled(screenBox)
  not (a.y + height <= b.y + b.h)

proc dropdown*(
    dropItems {.property: items.}: seq[string],
    dropSelected {.property: selected.}: var int,
): DropdownState {.statefulFidget.} =
  ## dropdown widget 
  init:
    size 8'em, 1.5'em
  
  properties:
    dropDownOpen: bool
    dropUp: bool
    itemsVisible: int

  render:
    let
      cb = current.box()
      bw = cb.w
      bh = cb.h
      bih = bh * 1.0
      tw = bw - 1'em

    echo fmt"pre: {self.itemsVisible=}"
    let
      visItems =
        if self.dropUp: 4
        elif self.dropDownOpen: self.itemsVisible
        else: dropItems.len()
      itemCount = max(1, visItems).min(dropItems.len())
      bdh = min(bih * itemCount.float32, windowLogicalSize.y/2)

    if itemCount <= 2:
      self.dropUp = true
      self.itemsVisible = dropItems.len()
      refresh()

    proc resetState() = 
      self.dropDownOpen = false
      self.dropUp = false
      self.itemsVisible = -1

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
        self.itemsVisible = -1

      text "text":
        box 0, 0, bw, bh
        fill "#ffffff"
        strokeWeight 1
        if dropSelected < 0:
          characters "Dropdown"
        else:
          characters dropItems[dropSelected]
      text "text":
        box tw, 0, 1'em, bh
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
          box 0, bh-bdh-bh, bw, bdh
        else:
          box 0, bh, bw, bdh

        clipContent true
        zlevel ZLevelRaised

        cornerRadius 3

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
          layout lmVertical
          counterAxisSizingMode csAuto
          horizontalPadding 0
          verticalPadding 0
          itemSpacing -1
          scrollBars true
          clipContent true

          onClickOutside:
            resetState()

          var itemsVisible = -1 + (if self.dropUp: -1 else: 0)
          for idx, buttonName in pairs(dropItems):
            group "itembtn":
              fill "#7CAFBC"
              box 0, 0, bw, 1.4*spad
            group "itembtn":
              if current.screenBox.overlaps(scrollBox):
                itemsVisible.inc()
              box 0, 0, bw, bih
              layoutAlign laCenter
              fill "#72bdd0"
              text "text":
                box 0, 0, bw, bih
                fill "#ffffff"
                characters buttonName

              onHover:
                fill "#5C8F9C"
                self.dropDownOpen = true
              onClick:
                resetState()
                echo "dropdown selected: ", buttonName
                dropSelected = idx
          group "itembtn":
            fill "#7CAFBC"
            box 0, 0, bw, 1.4*spad
          group "itempost":
            box 0, 0, bw, 12.5*spad
          
          echo fmt"post: {self.itemsVisible=}"
          if self.itemsVisible >= 0:
            self.itemsVisible = min(itemsVisible, self.itemsVisible)
          else:
            self.itemsVisible = itemsVisible
