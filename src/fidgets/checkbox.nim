import bumpy, fidget
import widgets

proc checkbox*(
    checked {.property: checked.}: bool,
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
    text "label":
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

    rectangle "square":
      box 0, 0, 1.4'em, 1.4'em
      fill theme
      if checked:
        highlight theme
        text "checkfil":
          box 0, 0, 1.4'em, 1.4'em
          fill textTheme.fill
          characters "✓"
      stroke theme.stroke
      cornerRadius 5
      strokeWeight 1
