import fidget
import widgets

proc checkbox*(
    checked {.property: value.}: var bool,
    message {.property: text.}: string,
    clicker {.property: onClick.}: WidgetProc = proc () = discard,
    isActive {.property: isActive.}: bool = false,
    disabled {.property: disabled.}: bool = false
): bool {.basicFidget, discardable.} =
  # Draw a progress bars
  init:
    box 0, 0, 8.Em, 2.Em
    # cornerRadius theme
    # strokeLine theme
    # fill theme
    # imageOf palette.gloss

  render:

    onClick:
      checked = not checked

    text "label":
      box 2'em, 0, parent.box.w - 2'em.UICoord, parent.box.h
      fill palette.text
      characters message

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
