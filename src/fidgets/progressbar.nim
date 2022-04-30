import std/strformat

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
    stroke theme.outerStroke

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
        fill theme.textFill
        characters label

    rectangle "barFgTexture":
      box sb, sb, barW, barH-sb
      cornerRadius 0.80 * theme.cornerRadius[0]
      clipContent true
      # strokeLine 1.0, "#707070", 0.87

    rectangle "barFgColor":
      box sb, sb, barW, barH-sb
      fill theme.foreground
      cornerRadius 0.80 * theme.cornerRadius[0]
      imageOf theme.gloss, 0.67
      stroke theme.innerStroke

    # Draw the bar itself.
    box 0, 0, bw, bh
    stroke theme.outerStroke
    fill theme.fill
    cornerRadius 1.0 * theme.cornerRadius[0]
    clipContent true
    rectangle "bezel":
      cornerRadius 0.80 * theme.cornerRadius[0]
      box 0, 0, 100'pw, 100'ph
      rotation 180
      imageOf theme.gloss

    cornerRadius 1.0 * theme.cornerRadius[0]