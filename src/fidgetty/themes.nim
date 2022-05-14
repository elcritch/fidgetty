import chroma
import fidget
import theming

proc grayTheme*(): Theme =
  let fs = 16'f32
  result.font("IBM Plex Sans", fs, 200, 0, hCenter, vCenter)
  result.corners(5)
  result.dropShadow(4, 0, 0, "#000000", 0.05)
  # result.fill = parseHtml("#CDCDCD").lighten(10'PP)
  result.foreground = parseHtml("#DDDDDD", 1.0)
  result.textFill = parseHtml("#565555")
  result.textCorner = common.uiScale * 1.2'f32
  result.textBg = parseHtml("#DFDFE0", 1.0).lighten(20'PP)
  result.highlight = parseHtml("#87E3FF", 0.77)
  result.outerStroke = stroke(1, "#707070", 1.0)
  result.innerStroke = stroke(1, "#707070", 0.4)
  result.gloss = imageStyle("shadow-button-middle.png", color(1, 1, 1, 0.27))
  result.cursor = parseHtml("#77D3FF", 0.33)
  result.itemSpacing = 0.001 * fs

proc bulmaTheme*(): Theme =
  # pallete.primary = hsl(171, 100'PP, 41'PP).to(Color)
  pallete.primary = rgb(27,202,162).to(Color) # parseHtml("#00d1b2")
  pallete.link = hsl(217, 71'PHSL, 53'PHSL).to(Color)
  pallete.info = hsl(204, 86'PHSL, 53'PHSL).to(Color)
  pallete.success = hsl(141, 53'PHSL, 53'PHSL).to(Color)
  pallete.warning = parseHtml("#ffdd57") # hsl(48, 100/360, 67/360).to(Color)
  pallete.danger = hsl(348, 100'PHSL, 61'PHSL).to(Color)

  let fs = 16'f32
  result.font("IBM Plex Sans", fs, 200, 0, hCenter, vCenter)
  result.corners(5)
  result.dropShadow(4, 0, 0, "#000000", 0.05)

  result.fill = pallete.primary * 1.0
  result.highlight = pallete.primary.saturate(10'PP) * 1.0
  result.background = whiteColor

  result.textFill = whiteColor
  result.textCorner = common.uiScale * 1.2'f32
  result.textBg = parseHtml("#DFDFE0", 1.0)
  result.foreground = parseHtml("#87E3FF", 0.77)
  result.outerStroke = stroke(0, "#707070", 1.0)
  result.innerStroke = stroke(1, "#707070", 0.4)
  # result.gloss = imageStyle("shadow-button-middle.png", color(1, 1, 1, 0.27))
  result.cursor = parseHtml("#77D3FF", 0.33)
  result.itemSpacing = 0.001 * fs

