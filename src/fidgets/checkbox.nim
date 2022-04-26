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
    imageColor theme

  render:

    onClick:
      checked = not checked

    text "label":
      fill textTheme
      characters message

    rectangle "square":
      box 0, 0, 2'em, 2'em
      fill theme
      clipContent true
      image "shadow-button-middle.png"
      imageColor theme
      if checked:
        highlight theme
        text "checkfil":
          textStyle textTheme.textStyle
          fontSize 1.4 * fontSize()
          box 0.15'em, 0.40'em, 1'em, 1'em
          fill textTheme.fill
          characters "✓"
      stroke theme.stroke
      cornerRadius theme
      strokeLine theme
