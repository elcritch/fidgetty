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
    imageOf theme.gloss
    rotation 0
    fill theme

  render:
    stroke theme.outerStroke

    text "text":
      fill theme.textFill
      binding value

    clipContent true
    if disabled:
      imageColor theme.disabled
    else:
      onHover:
        # imageTransparency 0.0
        rotation 180
        stroke theme.highlight * 0.40
        strokeWeight 0.2'em
      if isActive:
        highlight theme



