import fidget
import fidgetty/themes
import cdecl/applies

template fieldAfter*(
    label: string,
    width = 8'em,
    height = 2'em,
    padding = 0.68'em,
    align = hLeft,
    widget: untyped,
) =
  Horizontal:
    `widget`
    Spacer(padding, 0)
    text "label":
      size max(width, label.len()), height
      fill palette.text
      current.textStyle.textAlignHorizontal = align
      characters label

template field*(
    label: string,
    width = 8'em,
    height = 2'em,
    padding = 0.68'em,
    alig = hRight,
    widget: untyped,
) =
  Horizontal:
    text "label":
      size max(width, label.len()), height
      fill palette.text
      characters label
    `widget`

template FieldAfter*(blk: varargs[untyped]) =
  unpackLabelsAsArgs(fieldAfter, blk)

template Field*(blk: varargs[untyped]) =
  unpackLabelsAsArgs(fieldAfter, blk)
