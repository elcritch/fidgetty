import fidget
import fidgetty/widgets

export fidget
export widgets

proc grayTheme*() =
  setupWidgetTheme:
    let fs = 16'f32
    theme.font("IBM Plex Sans", fs, 200, 0, hCenter, vCenter)
    theme.corners(5)
    theme.dropShadow(4, 0, 0, "#000000", 0.05)
    theme.fill = parseHtml("#CDCDCD")
    theme.textFill = parseHtml("#565555")
    theme.textCorner = common.uiScale * 1.2'f32
    theme.textBg = parseHtml("#DFDFE0", 1.0)
    theme.foreground = parseHtml("#87E3FF", 0.77)
    # theme.highlight = parseHtml("#77D3FF", 0.77)
    theme.highlight = parseHtml("#87E3FF", 0.77)
    theme.outerStroke = stroke(1, "#707070", 1.0)
    theme.innerStroke = stroke(1, "#707070", 0.4)
    theme.gloss = imageStyle("shadow-button-middle.png", color(1, 1, 1, 0.27))
    theme.cursor = parseHtml("#77D3FF", 0.33)
    theme.itemSpacing = 0.001 * fs
