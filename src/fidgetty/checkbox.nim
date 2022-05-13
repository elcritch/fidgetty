import bumpy, fidget
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
    # imageOf theme.gloss

  render:

    onClick:
      checked = not checked

    text "label":
      box 2'em, 0, parent.box().w - 2'em, parent.box().h
      fill theme.textFill
      characters message

    rectangle "square":
      box 0, 0, 2'em, 2'em
      echo fmt"{theme.fill=}"
      fill theme
      clipContent true
      imageOf theme.gloss
      if checked:
        highlight theme
        text "checkfil":
          # textStyle theme.text.textStyle
          fontSize 1.4 * fontSize()
          box 0.15'em, 0.40'em, 1'em, 1'em
          fill theme.textFill
          characters "✓"
      stroke theme.outerStroke
      cornerRadius theme
