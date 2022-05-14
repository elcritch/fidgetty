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
    cornerRadius generalTheme
    shadows generalTheme
    stroke generalTheme.outerStroke
    imageOf generalTheme.gloss
    fill theme.fill

  render:
    text "text":
      fill theme.text
      characters message

    clipContent true
    if disabled:
      imageColor theme.disabled
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

