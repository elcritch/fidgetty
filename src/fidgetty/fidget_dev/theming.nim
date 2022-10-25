import std/strutils, std/tables, std/deques
import cdecl/atoms
import cdecl/[atoms, crc32]
import chroma

import commonutils, common
export atoms, commonutils, common

type
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
  themes: Themes = [initTable[Atom, Themer]()].toDeque

  noStroke* = Stroke.init(0.0'f32, "#000000", 0.0)

proc `..`*(a, b: Atom): Atom =
  b !& atom".." !& a

proc `/`*(a, b: Atom): Atom =
  b !& a

proc pushTheme*() =
  themes.addLast(themes.peekLast())

proc popTheme*() =
  themes.popLast()

template onTheme*(themes: Themes, name: Atom, blk: untyped) =
  if name in themes:
    `blk`

proc findThemer(idPath: seq[Atom], extra: Atom): Themer =
  # echo "findThemer:extra: ", $extra
  template runThemerIfFound(value: untyped) =
    result = themes.peekLast().getOrDefault(value, nil)
    if not result.isNil:
      return

  let id = idPath[^1]
  runThemerIfFound(extra !& id !& idPath[^2]) # check parent
  # check paths
  for idx in countdown(idPath.len()-2, 0):
    # check skip matches
    runThemerIfFound(extra !& id !& atom".." !& idPath[idx])
  
  # check self
  runThemerIfFound(extra !& id)
  # check attribute if given
  if extra != Atom(0):
    runThemerIfFound(extra)

template useThemeImpl*() =
  if current.themer.name != current.id:
    current.themer.name = current.id
    current.themer.cb = findThemer(current.idPath, Atom(0))
  
  if not current.themer.cb.isNil:
    current.themer.cb()

template themeExtra*(extra: Atom) =
  if current.themerExtra.name != extra:
    current.themerExtra.name = extra
    current.themerExtra.cb = findThemer(current.idPath, extra)
  
  if not current.themerExtra.cb.isNil:
    current.themerExtra.cb()

template setTheme*(name: Atom, blk: untyped) =
  let themer = proc() =
    `blk`
  themes.peekLast()[name] = themer

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
