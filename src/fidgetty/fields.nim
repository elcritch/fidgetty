import fidget
import fidgetty/theming
import cdecl/applies

proc basicLabel*(
    label: string,
    width = 2'em,
    height = 2'em,
    padding = 0.68'em,
    align = hCenter,
) =
  text "label":
    size max(width, label.len().float32.Em), height
    fill palette.text
    current.textStyle.textAlignHorizontal = align
    characters label

template fieldRight*(
    label: string,
    width = 2'em,
    height = 2'em,
    padding = 0.68'em,
    align = hLeft,
    widget: untyped,
) =
  Horizontal:
    `widget`
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
    `widget`

template FieldLeft*(blk: varargs[untyped]) =
  unpackLabelsAsArgs(fieldLeft, blk)

template FieldRight*(blk: varargs[untyped]) =
  unpackLabelsAsArgs(fieldRight, blk)
