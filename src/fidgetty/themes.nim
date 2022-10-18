import chroma
import fidget_dev
import fidget_dev/theming

proc grayTheme*() =

  palette.primary = parseHtml("#DDDDDD", 1.0)
  palette.link = palette.primary
  palette.info = palette.primary
  palette.success = palette.primary
  palette.warning = parseHtml("#ffdd57") # hsl(48, 100/360, 67/360).to(Color)
  palette.danger = palette.primary
  palette.textModeLight = parseHtml("#ffffff")
  palette.textModeDark = parseHtml("#000000")

  theme.foreground = parseHtml("#CDCDCF", 1.0)
  theme.background = parseHtml("#E4E4E6", 1.0)
  theme.text = parseHtml("#565555")
  # theme.textBg = parseHtml("#F6F5F5")
  theme.accent = parseHtml("#87E3FF", 0.77).desaturate(0.15)
  theme.highlight = parseHtml("#87E3FF", 0.77)
  theme.cursor = parseHtml("#77D3FF", 0.33)
  theme.cornerRadius = (5'ui, 5'ui, 5'ui, 5'ui)
  theme.outerStroke = Stroke.init(3.0'f32, "#707070", 0.12)
  theme.innerStroke = Stroke.init(1.0'f32, "#707070", 0.12)
  theme.textStyle.setFontStyle("IBM Plex Sans", 16, 200, 0, hCenter, vCenter)

  setTheme(atom"font"):
    cornerRadius common.uiScale * 3.2'f32
  
  setTheme(atom"basic"):
    cornerRadius common.uiScale * 3.2'f32
    dropShadow(4, 0, 0, "#000000", 0.05)
    stroke Stroke.init(2, "#707070", 1.0)
    image imageStyle("shadow-button-middle.png", color(1, 1, 1, 0.27))
    itemSpacing 0.001 * theme.textStyle.fontSize

  setTheme(atom"inner"):
    stroke theme.innerStroke
  
  setTheme(atom"highlight"):
    fill theme.highlight
  
  setTheme(atom"active"):
    fill theme.accent
  
  setTheme(atom"disabled"):
    fill theme.disabled

  setTheme(atom"hover"):
    fill theme.highlight
  
  setTheme(atom"text"):
    fill theme.highlight
    size csAuto(), csAuto()
    fill theme.text
  
  setTheme(atom"button"):
    fill theme.foreground
    cornerRadius theme.cornerRadius
    stroke theme.innerStroke
    image theme.gloss

  setTheme(atom"area"):
    fill theme.background
    cornerRadius theme.cornerRadius
    stroke theme.outerStroke

  setTheme(atom"container"):
    # fill theme.foreground
    cornerRadius theme.cornerRadius
    stroke theme.outerStroke

  setTheme(atom"filling"):
    fill theme.accent.lighten(0.07).desaturate(0.3) * 0.9
    cornerRadius theme.cornerRadius
    stroke theme.innerStroke
    image theme.gloss

  setTheme(atom"container" .. atom"outline"):
    # fill theme.foreground
    cornerRadius theme.cornerRadius
    stroke theme.outerStroke

  setTheme(atom"container" .. atom"button"):
    fill theme.foreground
    cornerRadius 0'ui
    stroke Stroke.init(1.0'f32, "#707070", 0.12)

  setTheme(atom"button" / atom"pop"):
    fill theme.highlight
    stroke Stroke.init(1.0'f32, "#303030", 0.90)

  # setTheme([atom"menu", atom"button"]):
  setTheme(atom"menu" / atom"button"):
    fill theme.foreground
    cornerRadius (0'ui,0'ui,0'ui,0'ui)
    stroke Stroke.init(0.0'f32, "#000000", 0.0)


proc bulmaTheme*() =
  # pallete.primary = hsl(171, 100'CPP, 41'CPP).to(Color)
  # palette.primary = parseHtml("#87E3FF", 1.0).saturate(0.3)
  palette.link = hsl(27, 100/255, 41/255).to(Color) # parseHtml("#00d1b2")
  palette.primary = parseHtml("#3273dc").desaturate(0.25) * 0.87 # hsl(217, 71'PHSL, 53'PHSL).to(Color)
  palette.info = hsl(204, 86/255, 53/255).to(Color)
  palette.success = hsl(141, 53/255, 53/255).to(Color)
  palette.warning = parseHtml("#ffdd57") # hsl(48, 100/360, 67/360).to(Color)
  palette.danger = hsl(348, 100/255, 61/255).to(Color)
  palette.textModeLight = parseHtml("#ffffff")
  palette.textModeDark = parseHtml("#000000")

  theme.foreground = palette.primary * 1.0
  theme.highlight = palette.primary.saturate(10.0) * 1.0
  theme.background = whiteColor
  theme.cursor = parseHtml("#77D3FF", 0.33)
  theme.text = palette.textModeDark
  theme.accent = parseHtml("#87E3FF", 0.77)
  theme.outerStroke = Stroke.init(0, "#707070", 3.0)
  theme.innerStroke = Stroke.init(0, "#707070", 1.0)
  theme.textStyle.setFontStyle("IBM Plex Sans", 16, 200, 0, hCenter, vCenter)

  let fs = 16'f32
  setTheme(atom"font"):
    stroke Stroke.init(1, "#707070", 0.4)
    itemSpacing 0.001 * fs.UICoord
    cornerRadius common.uiScale * 3.2'f32
  
  setTheme(atom"basic"):
    font("IBM Plex Sans", fs, 200, 0, hCenter, vCenter)
    cornerRadius(5)
    dropShadow(4, 0, 0, "#000000", 0.05)
    stroke Stroke.init(0, "#707070", 1.0)

  setTheme(atom"basic"):
    stroke Stroke.init(1, "#707070", 0.4)
    itemSpacing 0.001 * fs.UICoord
    cornerRadius common.uiScale * 3.2'f32


proc darkNimTheme*() =
  # pallete.primary = hsl(171, 100'CPP, 41'CPP).to(Color)
  # palette.primary = parseHtml("#87E3FF", 1.0).saturate(0.3)
  palette.link = hsl(27, 100/255, 41/255).to(Color) # parseHtml("#00d1b2")
  palette.primary = rgba(27,29,38,255).color
  palette.info = rgba(194,166,9,255).color
  palette.success = hsl(141, 53/255, 53/255).to(Color)
  palette.warning = parseHtml("#ffdd57") # hsl(48, 100/360, 67/360).to(Color)
  palette.danger = hsl(348, 100/255, 61/255).to(Color)
  palette.textModeLight = blackColor
  palette.textModeDark = whiteColor

  theme.foreground = palette.info
  theme.highlight = palette.info.lighten(0.14)
  theme.disabled = palette.info.darken(0.3)
  theme.background = rgba(27,29,38,255).color
  theme.cursor = whiteColor
  theme.text = whiteColor
  theme.accent = blackColor

  theme.textStyle.setFontStyle("IBM Plex Sans", 16, 200, 0, hCenter, vCenter)

  let fs = 16'f32
  setTheme(atom"font"):
    font("IBM Plex Sans", fs, 200, 0, hCenter, vCenter)
    cornerRadius 3.2'f32

  setTheme(atom"font"):
    cornerRadius(5)

  setTheme(atom"button"):
    cornerRadius theme.cornerRadius
    shadow theme.shadow
    stroke theme.outerStroke
    image theme.gloss
    fill theme.foreground

type
  ThemeAccents* = enum
    fgDarken,
    bgDarken,
    txtDark,
    txtHighlight

# template MakeDefaultPalette(name: untyped) =
#   proc `name Palette`*(accents: set[ThemeAccents] = {}): Palette =
#     ## Set sub-palette using `name` colors for widgets
#     result = palette()
#     result.highlight = palette.`name`.lighten(0.1)
#     if fgDarken in accents:
#       result.foreground = palette.`name`.darken(0.2)
#     else:
#       result.foreground = palette.`name`.lighten(0.2)
#     if bgDarken in accents:
#       result.background = result.background.darken(0.2)
#     if txtDark in accents:
#       result.text = palette.textModeLight
#     else:
#       result.text = palette.textModeDark
#     if txtHighlight in accents:
#       result.text = palette.`name`

# MakeDefaultPalette(info)
# MakeDefaultPalette(link)
# MakeDefaultPalette(success)
# MakeDefaultPalette(warning)
# MakeDefaultPalette(danger)
