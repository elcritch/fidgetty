import bumpy, fidget
import widgets

proc button*(
    message {.property: text.}: string,
    clicker {.property: onClick.}: WidgetProc = proc () = discard,
    isActive {.property: isActive.}: bool = false,
    disabled {.property: disabled.}: bool = false
): bool {.basicFidget, discardable.} =
  # Draw a progress bars 
  init:
    box 0, 0, 8.Em, 2.Em
    cornerRadius 3
    dropShadow 4, 0, 0, "#000000", 0.05
    strokeLine 2, "#707070", 1.0
    current.imageColor = color(1,1,1,0.37)

  render:
    let
      bw = current.box().w
      bh = current.box().h
      this = current

    text "text":
      box 0, 0, bw, bh
      fill "#565555"
      characters message

    element "barGloss":
      strokeLine parent
      clipContent true
      cornerRadius parent
      image "shadow-button-middle.png"
      current.imageColor = this.imageColor
      if disabled:
        current.imageColor = color(0,0,0,0.11)

    element "buttonHover":
      cornerRadius parent
      fill "#BDBDBD"
      if disabled:
        fill "#9D9D9D"
      else:
        onHover: 
          fill "#87E3FF", 0.97
        if isActive:
          fill "#87E3FF", 0.77
        onClick:
          fill "#77D3EF", 0.99
          if not clicker.isNil:
            clicker()
          result = true

      