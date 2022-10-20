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
): Events[All]=
  # Draw a progress bars
  # onClick:
  #   props.checked = not props.checked
  #   dispatchEvent Activated(props.checked)

  let bsize = height()
  text "label":
    # box bwidth, 0, parent.box.w - bwidth, bwidth
    box bsize, 0, csSum(100.0'pp, -bsize.UiScalar), bsize
    fill theme.text
    characters props.label

  rectangle "square":
    size parent.box.h, parent.box.h
    fill theme.foreground
    clipContent true
    image theme.gloss
    if props.checked:
      highlight theme.highlight
      text "checkfil":
        fontSize 1.6 * fontSize()
        box 0.0, 0.0, 1.2 * fontSize(), 100'pp
        fill theme.text
        characters "✓"
    stroke theme.outerStroke
    cornerRadius theme.cornerRadius
