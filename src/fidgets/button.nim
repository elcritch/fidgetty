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
    stroke theme.outerStroke
    imageOf theme.gloss
    fill theme

  render:
    text "text":
      fill theme.textFill
      characters message

    clipContent true
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

