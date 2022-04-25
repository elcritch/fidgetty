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
    fill theme

  render:
    let
      bw = current.box().w
      bh = current.box().h
      this = current

    text "text":
      fill textTheme
      characters message

    clipContent true
    image "shadow-button-middle.png"
    if disabled:
      imageColor color(0, 0, 0, 0.11)
    else:
      onHover:
        highlight theme
      if isActive:
        highlight theme
      onClick:
        highlight theme
        if not clicker.isNil:
          clicker()
        result = true

