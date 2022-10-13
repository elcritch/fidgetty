import std/strutils, std/tables, std/deques
import cdecl/atoms
import fidget_dev
import cdecl/[atoms, crc32]

type
  Themer = proc()

  Themes* = TableRef[Atom, Deque[Themer]]

  Palette* = object
    primary*: Color
    link*: Color
    info*: Color
    success*: Color
    warning*: Color
    danger*: Color
    textModeLight*: Color
    textModeDark*: Color

  BasicTheme* = object
    foreground*: Color
    accent*: Color
    highlight*: Color
    disabled*: Color
    background*: Color
    text*: Color
    cursor*: Color
    cornerRadius*: (UICoord, UICoord, UICoord, UICoord)
    shadow*: Option[Shadow]
    gloss*: ImageStyle
    textStyle*: TextStyle
    innerStroke*: Stroke
    outerStroke*: Stroke
    itemSpacing*: UICoord

var
  palette*: Palette
  theme*: BasicTheme
  themes*: Themes = newTable[Atom, Deque[Themer]]()

proc `[]`*(themes: Themes, name: Atom): var Themer =
  themes.mgetOrPut(name, [nil.Themer].toDeque()).peekLast()

proc contains*(themes: Themes, name: Atom): bool =
  not isNil(themes[name])

proc push*(themes: Themes, name: Atom, theme: Themer) =
  themes.mgetOrPut(name, initDeque[Themer]()).addLast(theme)

proc pop*(themes: Themes, name: Atom) =
  discard themes.mgetOrPut(name, initDeque[Themer]()).popLast()

template onTheme*(themes: Themes, name: Atom, blk: untyped) =
  if name in themes:
    `blk`

template useThemeImpl(name: Atom): bool =
  block:
    let themer = theming.themes[name]
    if not themer.isNil:
      themer()
      true
    else:
      false

template useTheme*(name: Atom) =
  var ran = false
  if not ran:
    ran = useThemeImpl(Atom(Crc32(current.id) !& Crc32(name)))
  if not ran:
    ran = useThemeImpl(name)

template useTheme*() =
  var ran = false
  if not ran:
    ran = useThemeImpl(Atom(Crc32(parent.id) !& Crc32(current.id)))
  if not ran:
    ran = useThemeImpl(current.id)

template setTheme*(name: Atom, blk: untyped) =
  let themer = proc() =
    `blk`
  themes.push(name, themer)

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

proc font*(
  item: var BasicTheme,
  fontFamily: string,
  fontSize, fontWeight, lineHeight: float32,
  textAlignHorizontal: HAlign,
  textAlignVertical: VAlign
) =
  item.textStyle.setFontStyle(
    fontFamily,
    fontSize,
    fontWeight,
    lineHeight,
    textAlignHorizontal,
    textAlignVertical)

proc fill*(item: var BasicTheme) =
  ## Sets background color.
  current.fill = item.foreground

proc strokeLine*(item: var Palette, weight: float32, color: string, alpha = 1.0) =
  ## Sets stroke/border color.
  current.stroke.color = parseHtmlColor(color)
  current.stroke.color.a = alpha
  current.stroke.weight = weight 
