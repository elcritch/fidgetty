
import widgets
import button

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

    widget button:
      setup:
        box 0, 0, bw, bh
        text "icon":
          box tw, 0, 1'em, bh
          fill "#000000"
          if self.dropDownOpen: rotation -90
          else: rotation 0
          characters ">"
      text:
        if dropSelected < 0: "Dropdown"
        else: dropItems[dropSelected]
      onHover:
        fill "#5C8F9C"
      onClick:
        self.dropDownOpen = true
        self.itemsVisible = -1
      post:
        if self.dropDownOpen:
          fill "#5C8F9C"

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

        group "dropDownBorder":
          box 0, 0, bw, bdh
          cornerRadius 3
          strokeLine 2, "#707070", 2.0
        group "dropDownBorderTop":
          fill "#BDBDBD"
          box 0, 0, bw, 6*spad
        group "dropDownBoarderBottom":
          fill "#BDBDBD"
          box 0, bdh-6*spad, bw, 6*spad

        group "menu":
          box spad, 6*spad, bw, bdh-6*spad
          layout lmVertical
          counterAxisSizingMode csAuto
          itemSpacing -1
          scrollBars true
          clipContent true

          onClickOutside:
            resetState()

          var itemsVisible = -1 + (if self.dropUp: -1 else: 0)
          for idx, buttonName in pairs(dropItems):
            group "menuSpacer":
              fill "#BDBDBD"
              box 0, 0, bw, 1.4*spad
            group "menuBtn":
              if current.screenBox.overlaps(scrollBox):
                itemsVisible.inc()
              box 0, 0, bw, bih
              layoutAlign laCenter

              text "menuText":
                box 0, 0, bw, bih
                fill "#000000"
                characters buttonName
              element "barFg":
                fill "#BDBDBD"
                cornerRadius 2.2
              element "barGloss":
                cornerRadius 2.2
                image "shadow-button-middle.png"
                current.imageColor = color(1,1,1,0.17)
              element "barHover":
                fill "#BDBDBD"
                onHover:
                  fill "#87E3FF", 0.37
                  self.dropDownOpen = true
                onClick:
                  resetState()
                  echo "dropdown selected: ", buttonName
                  dropSelected = idx


          group "menuBtnBlankBorderBottom":
            fill "#BDBDBD"
            box 0, 0, bw, 1.4*spad
          group "menuBtnBlankSpacer":
            box 0, 0, bw, 12.5*spad
          
          if self.itemsVisible >= 0:
            self.itemsVisible = min(itemsVisible, self.itemsVisible)
          else:
            self.itemsVisible = itemsVisible
