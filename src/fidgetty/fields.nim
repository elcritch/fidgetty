import widgets
import cdecl/applies

fidgetty BasicLabel:
  properties:
    label: string
    width: UICoord
    height: UICoord
    padding: UICoord
    align: HAlign
  state:
    empty: void

proc render*(
    props: BasicLabelProps,
    self: BasicLabelState,
): Events[All]=
  ## labels
  let lw = max(props.width, props.label.len().float32.Em) * 0.5
  size lw, props.height
  text "label":
    size lw, props.height
    fill palette.text
    current.textStyle.textAlignHorizontal = props.align
    characters props.label

template fieldRight*(
    label: string,
    width = 2'em,
    height = 2'em,
    padding = 0.68'em,
    align = hLeft,
    with: untyped,
) =
  Horizontal:
    size 0, 0
    `with`
    Spacer(padding, 0)
    basicLabel(label, width, height, padding, align)

template fieldLeft*(
    label: string,
    width = 2'em,
    height = 2'em,
    padding = 0.68'em,
    alig = hRight,
    widget: untyped,
) =
  Horizontal:
    basicLabel(label, width, height, padding, align)
    Spacer(padding, 0)
    `widget`

template FieldLeft*(blk: varargs[untyped]) =
  unpackLabelsAsArgs(fieldLeft, blk)

template FieldRight*(blk: varargs[untyped]) =
  unpackLabelsAsArgs(fieldRight, blk)
