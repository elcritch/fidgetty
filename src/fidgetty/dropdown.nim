import widgets
import button
import std/typetraits

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

proc new*(_: typedesc[DropdownProps]): DropdownProps =
  new result
  size 8'em, 1.5'em
  fill clearColor
  imageColor clearColor

proc render*(
    props: DropdownProps,
    self: DropdownState
): Events[ChangeEvent[int]]=
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
    size bw, bh
    clipContent true
    text "icon":
      box tw, 0, 1'em, bh
      fill theme.text
      if self.dropDownOpen: rotation -90
      else: rotation 0
      characters ">"
    label if props.selected < 0:
            props.defaultLabel
          else:
            props.items[props.selected]
    onClick:
      self.dropDownOpen = true
      self.itemsVisible = -1
    onClickOutside:
      outClick = true
  
  finally:
    if self.dropDownOpen:
      highlight theme.highlight

  if self.dropDownOpen:
    group "container":
      if self.dropUp:
        box 0, bh-bdh-bh, bw, bdh
      else:
        box 0, bh, bw, bdh

      clipContent true
      zlevel ZLevelRaised

      group "outline":
        box 0, 0, bw, bdh

      group "scrollpane":
        box 0, 0, bw, bdh
        layout lmVertical
        counterAxisSizingMode CounterAxisSizingMode.csAuto
        itemSpacing theme.itemSpacing
        scrollpane true

        onClickOutside:
          echo "outClick: ", outClick
          resetState()

        var itemsVisible = -1 + (if self.dropUp: -1 else: 0)
        for idx, buttonName in pairs(props.items):
          group "outline":
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
              onClick:
                resetState()
                dispatchEvent changed(idx)
            # do -> MouseEvent: # handle events from widget
            #   evClick:
            #     resetState()
            #     dispatchEvent changed(idx)

        # group "menuBtnBlankSpacer":
          # box 0, 0, bw, this.cornerRadius[0]
        
        if self.itemsVisible >= 0:
          self.itemsVisible = min(itemsVisible, self.itemsVisible)
        else:
          self.itemsVisible = itemsVisible
