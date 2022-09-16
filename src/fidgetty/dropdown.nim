import widgets
import button
import std/typetraits
import std/strformat

import print
export button

#   events(AnimatedEvents):
#     IncrementBar(increment: float)
#     JumpToValue(target: float)
#     CancelJump

fidgetty Dropdown:
  properties:
    items: seq[string]
    selected: int
    defaultLabel: string
    disabled: bool

  state:
    dropDownOpen: bool
    dropUp: bool
    itemsVisible: int
    itemsCount: int

# static:
#   assert DropdownArgs is WidgetArgs
#   assert DropdownState is WidgetState

proc new*(_: typedesc[DropdownProps]): DropdownProps =
  new result
  size 8'em, 1.5'em
  fill clearColor
  imageColor clearColor

proc render*(
    props: DropdownProps,
    self: DropdownState
): Events =
  ## dropdown widget 
  let
    cb = current.box
    bw = cb.w
    bh = cb.h
    bih = bh * 1.0'ui
    tw = bw - 1.5'em

  proc resetState() = 
    self.dropDownOpen = false
    self.dropUp = false
    self.itemsVisible = -1

  if self.itemsCount != props.items.len():
    # echo "new dropdowns" 
    self.itemsCount = props.items.len()
    resetState()

  let
    visItems =
      if self.dropUp: 4
      elif self.dropDownOpen: self.itemsVisible
      else: props.items.len()
    itemCount = max(1, visItems).min(props.items.len())
    bdh = min(bih * itemCount.UICoord, windowLogicalSize.descaled.y/2'ui)

  if itemCount <= 2:
    self.dropUp = true
    self.itemsVisible = props.items.len()
    refresh()

  let this = current
  var outClick = false

  Button:
    disabled props.disabled
    box 0, 0, bw, bh
    clipContent true
    text "icon":
      box tw, 0, 1'em, bh
      fill palette.text
      if self.dropDownOpen: rotation -90
      else: rotation 0
      characters ">"
    label if props.selected < 0:
            props.defaultLabel
          else:
            props.items[props.selected]
  do -> MouseEvent: # handle events from widget
    evClick:
      self.dropDownOpen = true
      self.itemsVisible = -1
    evClickOut:
      outClick = true
  finally:
    if self.dropDownOpen:
      highlight palette.highlight

  let spad = 1.0'f32
  if self.dropDownOpen:

    group "dropDownScroller":
      if self.dropUp:
        box 0, bh-bdh-bh, bw, bdh
      else:
        box 0, bh, bw, bdh

      clipContent true
      zlevel ZLevelRaised
      cornerRadius theme
      strokeLine this

      group "menuoutline":
        box 0, 0, bw, bdh
        cornerRadius theme
        stroke theme.outerStroke

      group "menu":
        box 0, 0, bw, bdh
        layout lmVertical
        counterAxisSizingMode csAuto
        itemSpacing theme.itemSpacing
        scrollBars true

        onClickOutside:
          # echo "outClick: ", outClick
          if outClick == true:
            resetState()

        var itemsVisible = -1 + (if self.dropUp: -1 else: 0)
        for idx, buttonName in pairs(props.items):
          group "menuBtn":
            if current.screenBox.overlaps(scrollBox):
              itemsVisible.inc()
            box 0, 0, bw, bih
            layoutAlign laCenter

            Button:
              clearShadows()
              let ic = this.image.color
              imageColor ic * 0.9
              boxOf parent
              cornerRadius 0
              stroke theme.innerStroke
              label buttonName
            do -> MouseEvent: # handle events from widget
              evClick:
                resetState()
                dispatchEvent ItemSelected(idx)

        # group "menuBtnBlankSpacer":
          # box 0, 0, bw, this.cornerRadius[0]
        
        if self.itemsVisible >= 0:
          self.itemsVisible = min(itemsVisible, self.itemsVisible)
        else:
          self.itemsVisible = itemsVisible
