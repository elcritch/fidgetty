import fidget
import widgets

proc checkbox*(
    checked : var bool,
    label : string,
    clicker : WidgetProc = proc () = discard,
    isActive : bool = false,
    disabled : bool = false
): bool {.basicFidget, discardable.} =
  # Draw a progress bars
  init:
    box 0, 0, 8.Em, 2.Em

  render:

    onClick:
      checked = not checked

    text "label":
      box 2'em, 0, parent.box.w - 2'em, parent.box.h
      fill palette.text
      characters label

    rectangle "square":
      box 0, 0, 2'em, 2'em
      # echo fmt"{palette.fill=}"
      fill palette.foreground
      clipContent true
      imageOf theme.gloss
      if checked:
        highlight palette
        text "checkfil":
          # textStyle palette.text.textStyle
          fontSize 1.4 * fontSize()
          box 0.15'em, 0.40'em, 1'em, 1'em
          fill palette.text
          characters "✓"
      stroke theme.outerStroke
      cornerRadius theme
