import chroma
import fidget
import theming

proc grayTheme*(): tuple[theme: Theme, general: GeneralTheme] =
  let fs = 16'f32

  result.theme.fill = parseHtml("#DDDDDD", 1.0)
  result.theme.text = parseHtml("#565555")
  result.theme.textBg = parseHtml("#F6F5F5")
  result.theme.accent = parseHtml("#87E3FF", 0.67)
  result.theme.highlight = parseHtml("#87E3FF", 0.77)
  result.theme.cursor = parseHtml("#77D3FF", 0.33)

  result.general.font("IBM Plex Sans", fs, 200, 0, hCenter, vCenter)
  result.general.corners(5)
  result.general.dropShadow(4, 0, 0, "#000000", 0.05)
  result.general.textCorner = common.uiScale * 1.2'f32
  result.general.outerStroke = stroke(1, "#707070", 1.0)
  result.general.innerStroke = stroke(1, "#707070", 0.4)
  result.general.gloss = imageStyle("shadow-button-middle.png", color(1, 1, 1, 0.27))
  result.general.itemSpacing = 0.001 * fs


proc bulmaTheme*(): tuple[theme: Theme, general: GeneralTheme] =
  # pallete.primary = hsl(171, 100'PP, 41'PP).to(Color)
  pallete.primary = rgb(27,202,162).to(Color) # parseHtml("#00d1b2")
  pallete.link = hsl(217, 71'PHSL, 53'PHSL).to(Color)
  pallete.info = hsl(204, 86'PHSL, 53'PHSL).to(Color)
  pallete.success = hsl(141, 53'PHSL, 53'PHSL).to(Color)
  pallete.warning = parseHtml("#ffdd57") # hsl(48, 100/360, 67/360).to(Color)
  pallete.danger = hsl(348, 100'PHSL, 61'PHSL).to(Color)

  let fs = 16'f32
  result.general.font("IBM Plex Sans", fs, 200, 0, hCenter, vCenter)
  result.general.corners(5)
  result.general.dropShadow(4, 0, 0, "#000000", 0.05)
  result.general.outerStroke = stroke(0, "#707070", 1.0)
  result.general.innerStroke = stroke(1, "#707070", 0.4)
  result.general.itemSpacing = 0.001 * fs
  result.general.textCorner = common.uiScale * 1.2'f32

  result.theme.fill = pallete.primary * 1.0
  result.theme.highlight = pallete.primary.saturate(10'PP) * 1.0
  result.theme.background = whiteColor
  result.theme.cursor = parseHtml("#77D3FF", 0.33)

  result.theme.text = whiteColor
  result.theme.accent = parseHtml("#87E3FF", 0.77)

