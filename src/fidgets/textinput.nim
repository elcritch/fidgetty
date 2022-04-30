import widgets

proc textInput*(
    value {.property: value.}: var string,
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
      binding value

    clipContent true
    if disabled:
      imageColor theme.disabled
    else:
      onHover:
        highlight theme
      if isActive:
        highlight theme


