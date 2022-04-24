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

  render:
    let
      bw = current.box().w
      bh = current.box().h

    element "button":
      cornerRadius parent
      strokeLine 2, "#707070", 2.0
      text "text":
        box 0, 0, bw, bh
        fill "#565555"
        characters message

    element "barGloss":
      cornerRadius parent
      clipContent true
      rectangle "barFg":
        cornerRadius parent
        box 0, 0, 100'pw, 100'ph
        image "shadow-button-middle.png"
        current.imageColor = color(1,1,1,0.37)
        if disabled:
          current.imageColor = color(0,0,0,0.11)

    element "buttonHover":
      dropShadow 4, 0, 0, "#000000", 0.05
      cornerRadius parent
      fill "#BDBDBD"
      if disabled:
        fill "#9D9D9D"
      else:
        onHover: 
          fill "#87E3FF", 0.77
        if isActive:
          fill "#87E3FF", 0.77
        onClick:
          fill "#87E3FF", 0.99
          if not clicker.isNil:
            clicker()
          result = true

      