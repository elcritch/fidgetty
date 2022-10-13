import std/strutils, std/tables, std/deques
import cdecl/atoms
import fidget_dev

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
    textBg*: Color
    cursor*: Color
    cornerRadius*: (UICoord, UICoord, UICoord, UICoord)
    shadow*: Option[Shadow]
    textStyle*: TextStyle


var
  palette*: Palette
  theme*: BasicTheme
  themes*: Themes = newTable[Atom, Deque[Themer]]()

proc `[]`*(themes: Themes, name: Atom): Themer =
  themes.mgetOrPut(name, initDeque[Themer]()).peekLast()

proc push*(themes: Themes, name: Atom, theme: Themer) =
  themes.mgetOrPut(name, initDeque[Themer]()).addLast(theme)

proc pop*(themes: Themes, name: Atom) =
  discard themes.mgetOrPut(name, initDeque[Themer]()).popLast()

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
