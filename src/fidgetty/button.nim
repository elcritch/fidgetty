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
    fill palette.foreground

  render:
    text "text":
      fill palette.text
      characters message

    clipContent true
    if disabled:
      imageColor palette.disabled
    else:
      onHover:
        highlight palette
      if isActive:
        highlight palette
      onClick:
        highlight palette
        if not clicker.isNil:
          clicker()
        result = true

