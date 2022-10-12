import std/strutils, std/tables, std/deques
import cdecl/atoms
import fidget_dev

type
  Themer = proc()

  Themes* = TableRef[Atom, Deque[Themer]]

  ThemePalette* = object
    primary*: Color
    link*: Color
    info*: Color
    success*: Color
    warning*: Color
    danger*: Color
    textModeLight*: Color
    textModeDark*: Color

  Palette* = object
    foreground*: Color
    accent*: Color
    highlight*: Color
    disabled*: Color
    background*: Color
    text*: Color
    textBg*: Color
    cursor*: Color


# if common.themes.len() == 0:
  # common.themes.add(if palette.isNil: emptyTheme() else: theme())

var
  themePalette*: ThemePalette
  currentPalette*: Palette
  themes*: Themes = newTable[Atom, Deque[Themer]]()

proc has*(themes: Themes, name: Atom) =
  themes.mgetOrPut(name, initDeque[Themer]()).addLast(theme)

proc push*(themes: Themes, name: Atom, theme: Themer) =
  themes.mgetOrPut(name, initDeque[Themer]()).addLast(theme)
proc pop*(themes: Themes, name: Atom) =
  discard themes[name].popLast()
template setTheme*(name: Atom, blk: untyped) =
  let themer = proc() =
    `blk`
  themes.push(name, themer)

template setupWidgetTheme*(blk) =
  block:
    `blk`
  common.current = nil

template palette*(): var ThemePalette =
  common.themePalette
template theme*(): var Palette =
  common.currentPalette

proc setFontStyle*(
  textStyle: var TextStyle,
  fontFamily: string,
  fontSize, fontWeight, lineHeight: float32,
  textAlignHorizontal: HAlign,
  textAlignVertical: VAlign
) =
  ## Sets the font.
  textStyle = TextStyle()
  textStyle.fontFamily = fontFamily
  textStyle.fontSize = fontSize.UICoord
  textStyle.fontWeight = fontWeight.UICoord
  textStyle.lineHeight =
      if lineHeight != 0.0: lineHeight.UICoord
      else: defaultLineHeight(textStyle)
  textStyle.textAlignHorizontal = textAlignHorizontal
  textStyle.textAlignVertical = textAlignVertical

# proc font*(
#   item: var GeneralTheme,
#   fontFamily: string,
#   fontSize, fontWeight, lineHeight: float32,
#   textAlignHorizontal: HAlign,
#   textAlignVertical: VAlign
# ) =
#   item.setFontStyle(
#     fontFamily,
#     fontSize,
#     fontWeight,
#     lineHeight,
#     textAlignHorizontal,
#     textAlignVertical)

# proc textStyle*(node: var GeneralTheme) =
#   ## Sets the font size.
#   common.current.textStyle = node.textStyle

proc fill*(item: var Palette) =
  ## Sets background color.
  current.fill = item.foreground

proc strokeLine*(item: var Palette, weight: float32, color: string, alpha = 1.0) =
  ## Sets stroke/border color.
  current.stroke.color = parseHtmlColor(color)
  current.stroke.color.a = alpha
  current.stroke.weight = weight 

# proc corners*(item: var GeneralTheme, a, b, c, d: float32) =
#   ## Sets all radius of all 4 corners.
#   item.cornerRadius = (a.UICoord, b.UICoord, c.UICoord, d.UICoord)

# proc corners*(item: var GeneralTheme, radius: float32) =
#   ## Sets all radius of all 4 corners.
#   item.corners(radius, radius, radius, radius)

# proc cornerRadius*(node: GeneralTheme) =
#   ## Sets all radius of all 4 corners.
#   current.cornerRadius = node.cornerRadius

# proc highlight*(node: var Palette) =
#   ## Sets the color of text selection.
#   current.highlightColor = node.highlight

# proc shadows*(node: var GeneralTheme) =
#   current.shadows = node.shadows

# proc dropShadow*(item: var GeneralTheme; blur, x, y: float32, color: string, alpha: float32) =
#   ## Sets drop shadow on an element
#   var c = parseHtmlColor(color)
#   c.a = alpha
#   let sh: Shadow =  Shadow(kind: DropShadow, blur: blur.UICoord, x: x.UICoord, y: y.UICoord, color: c)
#   item.shadows.add(sh)

# proc setup*(theme: Themer): proc() =
#   result = proc() =
#     let (th, gt) = theme()
#     push th
#     push gt

# proc setups*(args: varargs[proc()]): proc() =
#   result = proc() =
#     for fn in args:
#       fn()

# proc colorsWith*(
#     # th: Theme
#     fill: Color = clearColor,
# ) =
#   var th = palette
#   if fill != clearColor:
#     th.foreground = fill
#   push th
#   defer: pop(Palette)

# proc `'CPP`*(n: string): float32 =
#   ## numeric literal view height unit
#   result = parseFloat(n) / 100.0

# proc `'PHSL`*(n: string): float32 =
#   ## numeric literal view height unit
#   result = parseFloat(n) / 100.0 * 360.0
