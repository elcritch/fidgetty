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

proc render*(
    props: TextBoxProps,
    self: TextBoxState
): Events[All]=
  # button widget!
  characters props.label
  size props.label.len().float.Em/2.0+0.5'em, 2'em

  text "text":
    boxSizeOf parent
    # fill theme.text
    characters props.label

  clipContent true
  dispatchMouseEvents()