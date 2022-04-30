import widgets
import button

template dropUpY(n: Node, height: float32 = 0): bool =
  let a = n.descaled(screenBox)
  let b = root.descaled(screenBox)
  not (a.y + height <= b.y + b.h)

proc dropdown*(
    dropItems {.property: items.}: seq[string],
    dropSelected {.property: selected.}: var int,
    defaultLabel {.property: label.}: string = "Dropdown",
): DropdownState {.statefulFidget.} =
  ## dropdown widget 
  init:
    size 8'em, 1.5'em
    cornerRadius theme
    stroke theme.outerStroke
    imageOf theme.gloss

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
      tw = bw - 1.5'em

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

    let this = current
    widget button:
      setup:
        box 0, 0, bw, bh
        cornerRadius this
        strokeLine this
        shadows theme
        imageOf this
        text "icon":
          box tw, 0, 1'em, bh
          fill theme.textFill
          if self.dropDownOpen: rotation -90
          else: rotation 0
          characters ">"
      text:
        fill theme.textFill
        if dropSelected < 0: defaultLabel
        else: dropItems[dropSelected]
      onHover:
        # fill "#5C8F9C"
        highlight theme.highlight
      onClick:
        self.dropDownOpen = true
        self.itemsVisible = -1
      post:
        if self.dropDownOpen:
          highlight theme.foreground

    let spad = 1.0'f32
    if self.dropDownOpen:

      group "dropDownScroller":
        if self.dropUp:
          box 0, bh-bdh-bh, bw, bdh
        else:
          box 0, bh, bw, bdh

        clipContent true
        zlevel ZLevelRaised
        cornerRadius this
        strokeLine this

        group "menuoutline":
          box 0, 0, bw, bdh
          cornerRadius this
          stroke theme.outerStroke

        group "menu":
          box 0, 0, bw, bdh
          layout lmVertical
          counterAxisSizingMode csAuto
          itemSpacing theme.itemSpacing
          scrollBars true

          onClickOutside:
            resetState()

          var itemsVisible = -1 + (if self.dropUp: -1 else: 0)
          for idx, buttonName in pairs(dropItems):
            group "menuBtn":
              if current.screenBox.overlaps(scrollBox):
                itemsVisible.inc()
              box 0, 0, bw, bih
              layoutAlign laCenter

              let clicked = widget button:
                text: buttonName
                setup:
                  clearShadows()
                  let ic = this.image.color
                  imageColor Color(r: 0, g: 0, b: 0, a: 0.20 * ic.a)
                  boxOf parent
                  cornerRadius 0
                  stroke theme.innerStroke
              if clicked:
                resetState()
                echo fmt"dropdwon: set {dropSelected=}"
                dropSelected = idx


          # group "menuBtnBlankSpacer":
            # box 0, 0, bw, this.cornerRadius[0]
          
          if self.itemsVisible >= 0:
            self.itemsVisible = min(itemsVisible, self.itemsVisible)
          else:
            self.itemsVisible = itemsVisible
