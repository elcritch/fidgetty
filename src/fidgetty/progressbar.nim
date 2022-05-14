import widgets

proc progressbar*(
    value {.property: value.}: var float,
    label {.property: label.} = ""
) {.basicFidget.} =
  ## Draw a progress bars 

  init:
    box 0, 0, 100.WPerc, 2.Em
    textAutoResize tsHeight
    layoutAlign laStretch
    stroke generalTheme.outerStroke

  render:
    let
      # some basic calcs
      bw = current.box().w
      bh = current.box().h
      sb = 0.3'em
      sbb = 2*sb
      wcalc = bw * value.clamp(0, 1.0) - sbb + 0.001
      barW = wcalc.clamp(0.0, bw-sb)
      barH = bh - sb

    if label.len() > 0:
      text "text":
        box 0, 0, bw, bh
        fill theme.text
        characters label

    rectangle "barFgTexture":
      box sb, sb, barW, barH-sb
      cornerRadius 0.80 * generalTheme.cornerRadius[0]
      clipContent true
      # strokeLine 1.0, "#707070", 0.87

    rectangle "barFgColor":
      box sb, sb, barW, barH-sb
      fill theme.accent
      cornerRadius 0.80 * generalTheme.cornerRadius[0]
      imageOf generalTheme.gloss, 0.67
      clipContent true
      stroke generalTheme.innerStroke

    # Draw the bar itself.
    box 0, 0, bw, bh
    stroke generalTheme.outerStroke
    fill theme.fill
    cornerRadius 1.0 * generalTheme.cornerRadius[0]
    clipContent true
    rectangle "bezel":
      cornerRadius 0.80 * generalTheme.cornerRadius[0]
      box 0, 0, 100'pw, 100'ph
      rotation 180
      imageOf generalTheme.gloss

    cornerRadius 1.0 * generalTheme.cornerRadius[0]