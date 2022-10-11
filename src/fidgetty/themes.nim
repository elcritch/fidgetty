import chroma
import fidget_dev
import theming

proc grayTheme*() =
  let fs = 16'f32

  themePalette.primary = parseHtml("#DDDDDD", 1.0)
  themePalette.link = themePalette.primary
  themePalette.info = themePalette.primary
  themePalette.success = themePalette.primary
  themePalette.warning = parseHtml("#ffdd57") # hsl(48, 100/360, 67/360).to(Color)
  themePalette.danger = themePalette.primary
  themePalette.textModeLight = parseHtml("#ffffff")
  themePalette.textModeDark = parseHtml("#000000")

  currentPalette.foreground = parseHtml("#DDDDDD", 1.0)
  currentPalette.text = parseHtml("#565555")
  currentPalette.textBg = parseHtml("#F6F5F5")
  currentPalette.accent = parseHtml("#87E3FF", 0.67)
  currentPalette.highlight = parseHtml("#87E3FF", 0.77)
  currentPalette.cursor = parseHtml("#77D3FF", 0.33)

  setTheme(atom"font"):
    font("IBM Plex Sans", fs, 200, 0, hCenter, vCenter)
    cornerRadius common.uiScale * 3.2'f32
  
  setTheme(atom"basic"):
    cornerRadius common.uiScale * 3.2'f32
    dropShadow(4, 0, 0, "#000000", 0.05)
    stroke Stroke.init(2, "#707070", 1.0)
    image imageStyle("shadow-button-middle.png", color(1, 1, 1, 0.27))
    itemSpacing 0.001 * fs.UICoord

  setTheme(atom"inner"):
    stroke Stroke.init(1, "#707070", 0.4)


proc bulmaTheme*() =
  # pallete.primary = hsl(171, 100'CPP, 41'CPP).to(Color)
  # themePalette.primary = parseHtml("#87E3FF", 1.0).saturate(0.3)
  themePalette.link = hsl(27, 100/255, 41/255).to(Color) # parseHtml("#00d1b2")
  themePalette.primary = parseHtml("#3273dc").desaturate(0.25) * 0.87 # hsl(217, 71'PHSL, 53'PHSL).to(Color)
  themePalette.info = hsl(204, 86/255, 53/255).to(Color)
  themePalette.success = hsl(141, 53/255, 53/255).to(Color)
  themePalette.warning = parseHtml("#ffdd57") # hsl(48, 100/360, 67/360).to(Color)
  themePalette.danger = hsl(348, 100/255, 61/255).to(Color)
  themePalette.textModeLight = parseHtml("#ffffff")
  themePalette.textModeDark = parseHtml("#000000")

  currentPalette.foreground = themePalette.primary * 1.0
  currentPalette.highlight = themePalette.primary.saturate(10.0) * 1.0
  currentPalette.background = whiteColor
  currentPalette.cursor = parseHtml("#77D3FF", 0.33)
  currentPalette.text = themePalette.textModeDark
  currentPalette.accent = parseHtml("#87E3FF", 0.77)

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
  # themePalette.primary = parseHtml("#87E3FF", 1.0).saturate(0.3)
  themePalette.link = hsl(27, 100/255, 41/255).to(Color) # parseHtml("#00d1b2")
  themePalette.primary = rgba(27,29,38,255).color
  themePalette.info = rgba(194,166,9,255).color
  themePalette.success = hsl(141, 53/255, 53/255).to(Color)
  themePalette.warning = parseHtml("#ffdd57") # hsl(48, 100/360, 67/360).to(Color)
  themePalette.danger = hsl(348, 100/255, 61/255).to(Color)
  themePalette.textModeLight = blackColor
  themePalette.textModeDark = whiteColor

  let fs = 16'f32
  setTheme(atom"font"):
    font("IBM Plex Sans", fs, 200, 0, hCenter, vCenter)
    cornerRadius 3.2'f32

  setTheme(atom"font"):
    cornerRadius(5)
    currentPalette.foreground = themePalette.info
    currentPalette.highlight = themePalette.info.lighten(0.14)
    currentPalette.disabled = themePalette.info.darken(0.3)
    currentPalette.background = rgba(27,29,38,255).color
    currentPalette.cursor = whiteColor

  setTheme(atom"font"):
    currentPalette.text = whiteColor
    currentPalette.accent = blackColor

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
#     result.highlight = themePalette.`name`.lighten(0.1)
#     if fgDarken in accents:
#       result.foreground = themePalette.`name`.darken(0.2)
#     else:
#       result.foreground = themePalette.`name`.lighten(0.2)
#     if bgDarken in accents:
#       result.background = result.background.darken(0.2)
#     if txtDark in accents:
#       result.text = themePalette.textModeLight
#     else:
#       result.text = themePalette.textModeDark
#     if txtHighlight in accents:
#       result.text = themePalette.`name`

# MakeDefaultPalette(info)
# MakeDefaultPalette(link)
# MakeDefaultPalette(success)
# MakeDefaultPalette(warning)
# MakeDefaultPalette(danger)
