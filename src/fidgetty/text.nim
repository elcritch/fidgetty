import widgets

fidgetty TextBox:
  properties:
    label: string
    isActive: bool
    disabled: bool
  state:
    empty: void

proc new*(_: typedesc[TextBoxProps]): TextBoxProps =
  new result
  # setup code
  # box 0, 0, 8.Em, 2.Em
  cornerRadius theme

proc render*(
    props: TextBoxProps,
    self: TextBoxState
): Events =
  # button widget!
  characters props.label
  size props.label.len().float.Em/2.0+0.5'em, 2'em

  text "text":
    boxSizeOf parent
    fill palette.text
    characters props.label

  clipContent true
  dispatchMouseEvents()