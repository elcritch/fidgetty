import fidget

type
  Themer = proc(): Theme

  ThemePalette* = object
    primary*: Color    #hsl(171, 100%, 41%)
    link*: Color      #hsl(217, 71%, 53%)
    info*: Color      #hsl(204, 86%, 53%)
    success*: Color    #hsl(141, 53%, 53%)
    warning*: Color    #hsl(48, 100%, 67%)
    danger*: Color    #$hsl(348, 100%, 61%)

  Theme* = object
    cursor*: Color
    highlight*: Color
    foreground*: Color
    fill*: Color
    background*: Color
    disabled*: Color
    textFill*: Color
    textBg*: Color

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
  themes*: seq[Theme] = @[]
  pallete*: ThemePalette


template setupWidgetTheme*(blk) =
  block:
    `blk`
  common.current = nil

template theme*(): var Theme =
  common.themes[^1]

proc setTheme*(th: Theme) =
  themes.add th
proc popTheme*(): Theme {.discardable.} =
  themes.pop()

proc setFontStyle*(
  theme: var Theme,
  fontFamily: string,
  fontSize, fontWeight, lineHeight: float32,
  textAlignHorizontal: HAlign,
  textAlignVertical: VAlign
) =
  ## Sets the font.
  theme.textStyle = TextStyle()
  theme.textStyle.fontFamily = fontFamily
  theme.textStyle.fontSize = common.uiScale*fontSize
  theme.textStyle.fontWeight = common.uiScale*fontWeight
  theme.textStyle.lineHeight =
      if lineHeight != 0.0: common.uiScale*lineHeight
      else: common.uiScale*fontSize
  theme.textStyle.textAlignHorizontal = textAlignHorizontal
  theme.textStyle.textAlignVertical = textAlignVertical

proc font*(
  theme: var Theme,
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

proc textStyle*(node: var Theme) =
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

proc corners*(item: var Theme, a, b, c, d: float32) =
  ## Sets all radius of all 4 corners.
  let s = common.uiScale * 3
  item.cornerRadius = (s*a, s*b, s*c, s*d)

proc corners*(item: var Theme, radius: float32) =
  ## Sets all radius of all 4 corners.
  item.corners(radius, radius, radius, radius)

proc cornerRadius*(node: Node | Theme) =
  ## Sets all radius of all 4 corners.
  current.cornerRadius =  node.cornerRadius

proc highlight*(node: var Theme) =
  ## Sets the color of text selection.
  current.highlightColor = node.highlight

proc shadows*(node: var Theme) =
  current.shadows = node.shadows

proc dropShadow*(item: var Theme; blur, x, y: float32, color: string, alpha: float32) =
  ## Sets drop shadow on an element
  var c = parseHtmlColor(color)
  c.a = alpha
  let sh: Shadow =  Shadow(kind: DropShadow, blur: blur, x: x, y: y, color: c)
  item.shadows.add(sh)



proc defaultEmptyTheme(): Theme =
  let fs = 16'f32
  result.setFontStyle("IBM Plex Sans", fs, 200, 0, hCenter, vCenter)
  result.cornerRadius = (3'f32, 3'f32, 3'f32, 3'f32)
  result.textCorner = common.uiScale * 2'f32
  result.foreground = Color(r: 157/255, g: 157/255, b: 157/255, a: 1)
  result.cursor = Color(r: 114/255, g: 189/255, b: 208/255, a: 0.33)
  result.highlight = Color(r: 114/255, g: 189/255, b: 208/255, a: 0.77)
  result.itemSpacing = 0.001 * fs

let emptyTheme*: Themer = defaultEmptyTheme

proc setup*(theme: Themer): proc() =
  result = proc() =
    setTheme theme()

proc setups*(args: varargs[proc()]): proc() =
  result = proc() =
    for fn in args:
      fn()

proc themeWith*(
    # th: Theme
    fill: Color = clearColor,
) =
  var th = theme
  if fill != clearColor:
    th.fill = fill
  setTheme th
  defer: popTheme()
