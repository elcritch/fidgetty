import bumpy, fidget
import fidgets

export fidget, fidgets

proc button*(
    message {.property: text.}: string,
    clicker {.property: onClick.}: WidgetProc = proc () = discard
): bool {.basicFidget, discardable.} =
  # Draw a progress bars 
  init:
    box 0, 0, 8.Em, 2.Em

  render:
    let
      bw = current.box().w
      bh = current.box().h

    cornerRadius 2

    rectangle "button":
      box 0, 0, bw, bh
      cornerRadius 3
      strokeLine 2, "#707070", 2.0
      text "text":
        box 0, 0, bw, bh
        fill "#565555"
        characters message

    rectangle "barFg":
      box 0, 0, 100'pw, 100'ph
      cornerRadius 2.2
      clipContent true
      rectangle "barFg":
        cornerRadius 2.2
        box 0, 0, 100'pw, 100'ph
        image "shadow-button-middle.png"
        current.imageColor = color(1,1,1,0.37)

    rectangle "button":
      box 0, 0, bw, bh
      dropShadow 4, 0, 0, "#000000", 0.05
      cornerRadius 3
      fill "#BDBDBD"
      onHover: 
        fill "#87E3FF", 0.77
      onClick:
        fill "#87E3FF", 0.99
        clicker()
        result = true

      