
import widgets
import button

proc listbox*(
    items {.property: items.}: seq[string],
    selected {.property: selected.}: var int,
): DropdownState {.statefulFidget.} =
  ## dropdown widget 
  init:
    size 8'em, 1.5'em
    cornerRadius theme
    stroke theme.outerStroke
    imageOf theme.gloss

  properties:
    itemsVisible: int

  render:
    let
      cb = current.box()
      bw = cb.w
      bh = cb.h
      bih = bh * 1.0
      tw = bw - 1.5'em

    let
      visItems = items.len()
      itemCount = max(1, visItems).min(items.len())
      bdh = min(bih * itemCount.float32, windowLogicalSize.y/2)

    if itemCount <= 2:
      self.itemsVisible = items.len()
      refresh()

    proc resetState() = 
      self.itemsVisible = -1

    let spad = 1.0'f32

    box 0, bh, bw, bdh
    clipContent true

    group "menuoutline":
      box 0, 0, bw, bdh
      cornerRadius local
      stroke theme.outerStroke

    group "menu":
      box 0, 0, bw, bdh
      layout lmVertical
      counterAxisSizingMode csAuto
      itemSpacing -1
      scrollBars true

      onClickOutside:
        resetState()

      var itemsVisible = -1
      for idx, buttonName in pairs(items):
        group "menuBtn":
          if current.screenBox.overlaps(scrollBox):
            itemsVisible.inc()
          box 0, 0, bw, bih
          layoutAlign laCenter

          let clicked = widget button:
            text: buttonName
            setup:
              clearShadows()
              let ic = local.image.color
              imageColor Color(r: 0, g: 0, b: 0, a: 0.20 * ic.a)
              boxOf parent
              cornerRadius 0
              stroke theme.innerStroke
          if clicked:
            resetState()
            selected = idx

      if self.itemsVisible >= 0:
        self.itemsVisible = min(itemsVisible, self.itemsVisible)
      else:
        self.itemsVisible = itemsVisible
