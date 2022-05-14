import widgets

proc textInput*(
    value {.property: value.}: string,
    isActive {.property: isActive.}: bool = false,
    disabled {.property: disabled.}: bool = false
): Option[string] {.basicFidget, discardable.} =
  # Draw a progress bars
  init:
    box 0, 0, 8.Em, 2.Em
    cornerRadius generalTheme.textCorner
    shadows generalTheme
    imageOf generalTheme.gloss
    imageTransparency 0.33
    rotation 0
    fill theme

  render:
    stroke generalTheme.outerStroke

    text "text":
      fill theme.text
      binding(value):
        if value != keyboard.input:
          result = some keyboard.input

    fill theme.textBg
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

proc textInputBind*(
    value {.property: value.}: var string,
    isActive {.property: isActive.}: bool = false,
    disabled {.property: disabled.}: bool = false,
): bool {.wrapperFidget, discardable.} =
  # Draw a progress bars
  let curr = value
  let res = textInput(curr, isActive, disabled, setup, post, id)
  if res.isSome:
    value = res.get()

