import widgets
import button

proc listbox*(
    items {.property: items.}: seq[string],
    selected {.property: selected.}: var int,
    itemsVisible {.property: itemsVisible.}: int
): ListBoxState {.statefulFidget.} =
  ## dropdown widget 
  init:
    size 8'em, 1.5'em
    cornerRadius theme
    stroke theme.outerStroke
    imageOf theme.gloss

  properties:
    showScrollBars: bool

  render:
    let
      cb = current.box()
      bw = cb.w
      bh = cb.h
      bih = bh * 1.0

    let
      visItems = items.len()
      bdh = min(bih * itemsVisible.float32, windowLogicalSize.y/2)

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

      for idx, buttonName in pairs(items):
        group "menuBtn":
          box 0, 0, bw, bih
          layoutAlign laCenter

          let clicked = widget button:
            text: buttonName
            isActive: idx == selected
            setup:
              clearShadows()
              let ic = local.image.color
              imageColor Color(r: 0, g: 0, b: 0, a: 0.20 * ic.a)
              boxOf parent
              cornerRadius 0
              stroke theme.innerStroke
          if clicked:
            selected = idx
