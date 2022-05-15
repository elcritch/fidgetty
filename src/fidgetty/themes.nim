import chroma
import fidget
import theming

proc grayTheme*(): tuple[palette: Palette, general: GeneralTheme] =
  let fs = 16'f32

  themePalette.primary = parseHtml("#DDDDDD", 1.0)
  themePalette.link = themePalette.primary
  themePalette.info = themePalette.primary
  themePalette.success = themePalette.primary
  themePalette.warning = themePalette.primary
  themePalette.danger = themePalette.primary
  themePalette.danger = themePalette.primary
  themePalette.textLight = parseHtml("#ffffff")
  themePalette.textDark = parseHtml("#000000")

  result.palette.foreground = parseHtml("#DDDDDD", 1.0)
  result.palette.text = parseHtml("#565555")
  result.palette.textBg = parseHtml("#F6F5F5")
  result.palette.accent = parseHtml("#87E3FF", 0.67)
  result.palette.highlight = parseHtml("#87E3FF", 0.77)
  result.palette.cursor = parseHtml("#77D3FF", 0.33)

  result.general.font("IBM Plex Sans", fs, 200, 0, hCenter, vCenter)
  result.general.corners(5)
  result.general.dropShadow(4, 0, 0, "#000000", 0.05)
  result.general.textCorner = common.uiScale * 1.2'f32
  result.general.outerStroke = stroke(1, "#707070", 1.0)
  result.general.innerStroke = stroke(1, "#707070", 0.4)
  result.general.gloss = imageStyle("shadow-button-middle.png", color(1, 1, 1, 0.27))
  result.general.itemSpacing = 0.001 * fs


proc bulmaTheme*(): tuple[palette: Palette, general: GeneralTheme] =
  # pallete.primary = hsl(171, 100'PP, 41'PP).to(Color)
  # themePalette.primary = parseHtml("#87E3FF", 1.0).saturate(0.3)
  themePalette.link = hsl(27, 100'PHSL, 41'PHSL).to(Color) # parseHtml("#00d1b2")
  themePalette.primary = parseHtml("#3273dc") * 0.87 # hsl(217, 71'PHSL, 53'PHSL).to(Color)
  themePalette.info = hsl(204, 86'PHSL, 53'PHSL).to(Color)
  themePalette.success = hsl(141, 53'PHSL, 53'PHSL).to(Color)
  themePalette.warning = parseHtml("#ffdd57") # hsl(48, 100/360, 67/360).to(Color)
  themePalette.danger = hsl(348, 100'PHSL, 61'PHSL).to(Color)
  themePalette.textLight = parseHtml("#ffffff")
  themePalette.textDark = parseHtml("#000000")

  let fs = 16'f32
  result.general.font("IBM Plex Sans", fs, 200, 0, hCenter, vCenter)
  result.general.corners(5)
  result.general.dropShadow(4, 0, 0, "#000000", 0.05)
  result.general.outerStroke = stroke(0, "#707070", 1.0)
  result.general.innerStroke = stroke(1, "#707070", 0.4)
  result.general.itemSpacing = 0.001 * fs
  result.general.textCorner = common.uiScale * 1.2'f32

  result.palette.foreground = themePalette.primary * 1.0
  result.palette.highlight = themePalette.primary.saturate(10'PP) * 1.0
  result.palette.background = whiteColor
  result.palette.cursor = parseHtml("#77D3FF", 0.33)

  result.palette.text = whiteColor
  result.palette.accent = parseHtml("#87E3FF", 0.77)

