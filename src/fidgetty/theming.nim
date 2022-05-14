import fidget

type
  Themer = proc(): tuple[theme: Theme, general: GeneralTheme]

  ThemePalette* = object
    primary*: Color
    link*: Color
    info*: Color
    success*: Color
    warning*: Color
    danger*: Color

  Theme* = object
    fill*: Color
    accent*: Color
    highlight*: Color
    disabled*: Color
    background*: Color
    text*: Color
    textBg*: Color
    cursor*: Color

  GeneralTheme* = object
    textStyle*: TextStyle
    textCorner*: float32
    innerStroke*: Stroke
    outerStroke*: Stroke
    gloss*: ImageStyle
    cornerRadius*: (float32, float32, float32, float32)
    shadows*: seq[Shadow]
    horizontalPadding*: float32
    verticalPadding*: float32
    itemSpacing*: float32


# if common.themes.len() == 0:
  # common.themes.add(if theme.isNil: emptyTheme() else: theme())

var
  themeStack*: seq[Theme] = @[]
  generalThemeStack*: seq[GeneralTheme] = @[]
  pallete*: ThemePalette


template setupWidgetTheme*(blk) =
  block:
    `blk`
  common.current = nil

template theme*(): var Theme =
  common.themeStack[^1]
template generalTheme*(): var GeneralTheme =
  common.generalThemeStack[^1]

proc push*(th: Theme) =
  themeStack.add th
proc pop*(tp: typedesc[Theme]): Theme {.discardable.} =
  themeStack.pop()

proc push*(th: GeneralTheme) =
  generalThemeStack.add th
proc pop*(tp: typedesc[GeneralTheme]): GeneralTheme {.discardable.} =
  generalThemeStack.pop()

proc setFontStyle*(
  general: var GeneralTheme,
  fontFamily: string,
  fontSize, fontWeight, lineHeight: float32,
  textAlignHorizontal: HAlign,
  textAlignVertical: VAlign
) =
  ## Sets the font.
  general.textStyle = TextStyle()
  general.textStyle.fontFamily = fontFamily
  general.textStyle.fontSize = common.uiScale*fontSize
  general.textStyle.fontWeight = common.uiScale*fontWeight
  general.textStyle.lineHeight =
      if lineHeight != 0.0: common.uiScale*lineHeight
      else: common.uiScale*fontSize
  general.textStyle.textAlignHorizontal = textAlignHorizontal
  general.textStyle.textAlignVertical = textAlignVertical

proc font*(
  theme: var GeneralTheme,
  fontFamily: string,
  fontSize, fontWeight, lineHeight: float32,
  textAlignHorizontal: HAlign,
  textAlignVertical: VAlign
) =
  theme.setFontStyle(
    fontFamily,
    fontSize,
    fontWeight,
    lineHeight,
    textAlignHorizontal,
    textAlignVertical)

proc textStyle*(node: var GeneralTheme) =
  ## Sets the font size.
  common.current.textStyle = node.textStyle

proc fill*(item: var Theme) =
  ## Sets background color.
  current.fill = item.fill

proc strokeLine*(item: var Theme, weight: float32, color: string, alpha = 1.0) =
  ## Sets stroke/border color.
  current.stroke.color = parseHtmlColor(color)
  current.stroke.color.a = alpha
  current.stroke.weight = weight * common.uiScale

proc corners*(item: var GeneralTheme, a, b, c, d: float32) =
  ## Sets all radius of all 4 corners.
  let s = common.uiScale * 3
  item.cornerRadius = (s*a, s*b, s*c, s*d)

proc corners*(item: var GeneralTheme, radius: float32) =
  ## Sets all radius of all 4 corners.
  item.corners(radius, radius, radius, radius)

proc cornerRadius*(node: GeneralTheme) =
  ## Sets all radius of all 4 corners.
  current.cornerRadius =  node.cornerRadius

proc highlight*(node: var Theme) =
  ## Sets the color of text selection.
  current.highlightColor = node.highlight

proc shadows*(node: var GeneralTheme) =
  current.shadows = node.shadows

proc dropShadow*(item: var GeneralTheme; blur, x, y: float32, color: string, alpha: float32) =
  ## Sets drop shadow on an element
  var c = parseHtmlColor(color)
  c.a = alpha
  let sh: Shadow =  Shadow(kind: DropShadow, blur: blur, x: x, y: y, color: c)
  item.shadows.add(sh)

proc setup*(theme: Themer): proc() =
  result = proc() =
    let (th, gt) = theme()
    push th
    push gt

proc setups*(args: varargs[proc()]): proc() =
  result = proc() =
    for fn in args:
      fn()

proc colorsWith*(
    # th: Theme
    fill: Color = clearColor,
) =
  var th = theme
  if fill != clearColor:
    th.fill = fill
  push th
  defer: pop(Theme)

proc `'PP`*(n: string): float32 =
  ## numeric literal view height unit
  result = parseFloat(n) / 100.0

proc `'PHSL`*(n: string): float32 =
  ## numeric literal view height unit
  result = parseFloat(n) / 100.0 * 360.0
