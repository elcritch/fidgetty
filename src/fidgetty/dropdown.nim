import widgets
import button

template dropUpY(n: Node, height: float32 = 0): bool =
  let a = n.descaled(screenBox)
  let b = root.descaled(screenBox)
  not (a.y + height <= b.y + b.h)

proc dropdown*(
    items : seq[string],
    selected : var int,
    defaultLabel : string = "Dropdown",
): DropdownState {.statefulFidget.} =
  ## dropdown widget 
  init:
    size 8'em, 1.5'em
    fill clearColor
    imageColor clearColor

  properties:
    dropDownOpen: bool
    dropUp: bool
    itemsVisible: int

  render:
    let
      cb = current.box
      bw = cb.w
      bh = cb.h
      bih = bh * 1.0'ui
      tw = bw - 1.5'em.UICoord

    let
      visItems =
        if self.dropUp: 4
        elif self.dropDownOpen: self.itemsVisible
        else: items.len()
      itemCount = max(1, visItems).min(items.len())
      bdh = min(bih * itemCount.UICoord, windowLogicalSize.descaled.y/2'ui)

    if itemCount <= 2:
      self.dropUp = true
      self.itemsVisible = items.len()
      refresh()

    proc resetState() = 
      self.dropDownOpen = false
      self.dropUp = false
      self.itemsVisible = -1

    let this = current

    Button:
      setup:
        box 0, 0, bw, bh
        # cornerRadius theme
        # strokeLine this
        # shadows theme
        # imageOf this
        clipContent true
        text "icon":
          box tw, 0, 1'em, bh
          fill palette.text
          if self.dropDownOpen: rotation -90
          else: rotation 0
          characters ">"
      label:
        if selected < 0: defaultLabel
        else: items[selected]
      # onHover:
      #   # fill "#5C8F9C"
      #   highlight palette.highlight
      onClick:
        self.dropDownOpen = true
        self.itemsVisible = -1
      post:
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
            resetState()

          var itemsVisible = -1 + (if self.dropUp: -1 else: 0)
          for idx, buttonName in pairs(items):
            group "menuBtn":
              if current.screenBox.overlaps(scrollBox):
                itemsVisible.inc()
              box 0, 0, bw, bih
              layoutAlign laCenter

              let clicked = Button:
                label: buttonName
                setup:
                  clearShadows()
                  let ic = this.image.color
                  imageColor Color(r: 0, g: 0, b: 0, a: 0.20 * ic.a)
                  boxOf parent
                  cornerRadius 0
                  stroke theme.innerStroke
              if clicked:
                resetState()
                echo fmt"dropdwon: set {selected=}"
                selected = idx


          # group "menuBtnBlankSpacer":
            # box 0, 0, bw, this.cornerRadius[0]
          
          if self.itemsVisible >= 0:
            self.itemsVisible = min(itemsVisible, self.itemsVisible)
          else:
            self.itemsVisible = itemsVisible
