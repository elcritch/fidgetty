import widgets

import print
proc button*(
    label {.property: label.}: string,
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
      boxSizeOf parent
      # xy 1.Em, 1.Em
      fill palette.text
      characters label
      textAutoResize tsHeight
      # centeredWH 50'pw, 50'ph
      # print "\nbutton:", parent.box, parent.screenBox, current.box, current.screenBox

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
