import widgets

fidgetty Button:
  properties:
    label: string
    isActive: bool
    disabled: bool
  state:
    empty: void

proc themeButton*() =
  cornerRadius theme.cornerRadius
  shadows theme.shadows
  stroke theme.outerStroke
  imageOf theme.gloss
  fill palette.foreground

proc new*(_: typedesc[ButtonProps]): ButtonProps =
  new result
  # setup code
  # box 0, 0, 8.Em, 2.Em
  themeButton()

proc render*(
    props: ButtonProps,
    self: ButtonState
): Events[All]=
  # button widget!
  text "button text":
    # boxSizeOf parent
    size csAuto(), csAuto()
    fill palette.text
    characters props.label
    # textAutoResize tsHeight

  clipContent true

  if props.disabled:
    # imageColor palette.disabled
    fill palette.disabled
  else:
    onHover:
      highlight palette
    if props.isActive:
      highlight palette
    onClick:
      highlight palette
    dispatchMouseEvents()