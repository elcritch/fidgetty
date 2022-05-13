import fidget
import fidgetty/themes
import fidgetty/widgets

export fidget
export widgets

proc grayTheme*(): Theme =
  let fs = 16'f32
  result.font("IBM Plex Sans", fs, 200, 0, hCenter, vCenter)
  result.corners(5)
  result.dropShadow(4, 0, 0, "#000000", 0.05)
  result.fill = parseHtml("#CDCDCD")
  result.textFill = parseHtml("#565555")
  result.textCorner = common.uiScale * 1.2'f32
  result.textBg = parseHtml("#DFDFE0", 1.0)
  result.foreground = parseHtml("#87E3FF", 0.77)
  result.highlight = parseHtml("#87E3FF", 0.77)
  result.outerStroke = stroke(1, "#707070", 1.0)
  result.innerStroke = stroke(1, "#707070", 0.4)
  result.gloss = imageStyle("shadow-button-middle.png", color(1, 1, 1, 0.27))
  result.cursor = parseHtml("#77D3FF", 0.33)
  result.itemSpacing = 0.001 * fs

proc bulmaTheme*(): Theme =
  let fs = 16'f32
  result.font("IBM Plex Sans", fs, 200, 0, hCenter, vCenter)
  result.corners(5)
  result.dropShadow(4, 0, 0, "#000000", 0.05)
  result.foreground = parseHtml("#CDCDCD")
  result.textFill = parseHtml("#565555")
  result.textCorner = common.uiScale * 1.2'f32
  result.textBg = parseHtml("#DFDFE0", 1.0)
  result.foreground = parseHtml("#87E3FF", 0.77)
  result.highlight = parseHtml("#87E3FF", 0.77)
  result.outerStroke = stroke(1, "#707070", 1.0)
  result.innerStroke = stroke(1, "#707070", 0.4)
  result.gloss = imageStyle("shadow-button-middle.png", color(1, 1, 1, 0.27))
  result.cursor = parseHtml("#77D3FF", 0.33)
  result.itemSpacing = 0.001 * fs

  pallete.primary = hsl(171, 100/360, 41/360).to(Color)
  pallete.link = hsl(217, 71/360, 53/360).to(Color)
  pallete.info = hsl(204, 86/360, 53/360).to(Color)
  pallete.success = hsl(141, 53/360, 53/360).to(Color)
  pallete.warning = hsl(48, 100/360, 67/360).to(Color)
  pallete.danger = hsl(348, 100/360, 61/360).to(Color)
