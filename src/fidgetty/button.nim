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

  if props.label.len() > 0:
    text "text":
      # boxSizeOf parent
      size csAuto(), csAuto()
      fill theme.text
      characters props.label

  if props.disabled:
    fill theme.disabled
    themeExtra atom"disabled"
  else:
    if props.isActive:
      themeExtra atom"active"
    onHover:
      themeExtra atom"hover"
    # onClick:
    #   useTheme atom"active"
    # dispatchMouseEvents()