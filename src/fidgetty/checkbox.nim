import fidget_dev
import widgets

fidgetty Checkbox:
  properties:
    checked: bool
    label: string
    isActive: bool
    disabled: bool
  state:
    empty: void

proc new*(_: typedesc[CheckboxProps]): CheckboxProps =
  new result
  echo "new checkbox"
  box 0, 0, 8.Em, 2.Em

proc render*(
    props: CheckboxProps,
    self: CheckboxState
): Events =
  # Draw a progress bars
  # onClick:
  #   props.checked = not props.checked
  #   dispatchEvent Activated(props.checked)

  text "label":
    box parent.box.h, 0, parent.box.w - parent.box.h, parent.box.h
    fill palette.text
    characters props.label

  rectangle "square":
    size parent.box.h, parent.box.h
    boxSizeOf parent
    fill palette.foreground
    clipContent true
    imageOf theme.gloss
    if props.checked:
      highlight palette
      text "checkfil":
        fontSize 1.6 * fontSize()
        box 0.0, 0.0, 1.2 * fontSize(), 100'pp
        fill palette.text
        characters "✓"
    stroke theme.outerStroke
    cornerRadius theme
