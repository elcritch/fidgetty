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
    cornerRadius theme
    shadows theme
    strokeLine theme
    imageColor theme

  render:
    let
      bw = current.box().w
      bh = current.box().h
      this = current

    text "text":
      box 0, 0, bw, bh
      fill textTheme
      characters message

    element "barGloss":
      strokeLine parent
      clipContent true
      cornerRadius parent
      image "shadow-button-middle.png"
      imageColor this.imageColor
      if disabled:
        imageColor color(0,0,0,0.11)

    element "buttonHover":
      cornerRadius parent
      fill "#BDBDBD"
      if disabled:
        fill "#9D9D9D"
      else:
        onHover: 
          fill theme.highlightColor
        if isActive:
          fill theme.highlightColor
        onClick:
          fill theme.highlightColor
          if not clicker.isNil:
            clicker()
          result = true

      