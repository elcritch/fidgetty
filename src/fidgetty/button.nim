import widgets

fidgetty Button:
  properties:
    label: string
    isActive: bool
    disabled: bool
  state:
    empty: void

proc new*(_: typedesc[ButtonProps]): ButtonProps =
  new result
  # setup code
  # box 0, 0, 8.Em, 2.Em
  cornerRadius theme
  shadows theme
  stroke theme.outerStroke
  imageOf theme.gloss
  fill palette.foreground

proc render*(
    props: ButtonProps,
    self: ButtonState
): Events =
  # button widget!
  text "button text":
    boxSizeOf parent
    fill palette.text
    characters props.label
    # textAutoResize tsHeight

  clipContent true

  if props.disabled:
    imageColor palette.disabled
    fill palette.disabled
  else:
    onHover:
      highlight palette
    if props.isActive:
      highlight palette
    onClick:
      highlight palette
    dispatchMouseEvents()