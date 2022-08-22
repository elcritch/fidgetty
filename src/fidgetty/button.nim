import widgets

proc button*(
    label : string,
    doClick : WidgetProc = proc () = discard,
    isActive : bool = false,
    disabled : bool = false
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
      boxSizeOf parent
      fill palette.text
      characters label
      textAutoResize tsHeight

    clipContent true
    if disabled:
      imageColor palette.disabled
      fill palette.disabled
    else:
      onHover:
        highlight palette
      if isActive:
        highlight palette
      onClick:
        highlight palette
        if not doClick.isNil:
          doClick()
        result = true
