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

proc render*(
    props: ButtonProps,
    self: ButtonState
): Events[All]=
  # button widget!
  # onTheme 
  clipContent true

  text "button text":
    # boxSizeOf parent
    size csAuto(), csAuto()
    fill theme.text
    characters props.label
    # textAutoResize tsHeight

  if props.disabled:
    # imageColor palette.disabled
    fill theme.disabled
  else:
    if props.isActive:
      highlight theme.highlight
    onHover:
      highlight theme.highlight
    onClick:
      highlight theme.highlight
    dispatchMouseEvents()