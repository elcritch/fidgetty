import std/strformat

import widgets

proc progressbar*(
    value {.property: value.}: var float,
    label {.property: label.} = ""
) {.basicFidget.} =
  ## Draw a progress bars 

  init:
    ## called before `setup` and used for setting defaults like
    ## the default box size
    box 0, 0, 100.WPerc, 2.Em
    textAutoResize tsHeight
    layoutAlign laStretch
    strokeLine theme

  render:
    let
      # some basic calcs
      bw = current.box().w
      bh = current.box().h
      sw = 2.0'f32
      sb = 4.0'f32
      wcalc = bw * float(value) - sb*sw + 0.001
      barW = wcalc.clamp(0.0, bw-sb*sw)
      barH = bh - sb*sw

    if label.len() > 0:
      text "text":
        box 0, 0, bw, bh
        fill "#565555"
        characters label

    # Draw the bar itself.
    group "bar":
      box 0, 0, bw, bh
      fill "#BDBDBD", 0.33
      strokeLine parent
      cornerRadius 1.0 * theme.cornerRadius[0]
      clipContent true
      rectangle "bezel":
        cornerRadius 0.80 * theme.cornerRadius[0]
        box 0, 0, 100'pw, 100'ph
        image "shadow-button-middle.png"
        rotation 180
        imageColor theme

    rectangle "barFgTexture":
      box sb, sb, barW, barH
      cornerRadius 0.80 * theme.cornerRadius[0]
      clipContent true
      strokeLine 1.0, "#707070", 0.87

    rectangle "barFgColor":
      box sb, sb, barW, barH
      fill "#87E3FF"
      cornerRadius 0.80 * theme.cornerRadius[0]

    cornerRadius 1.0 * theme.cornerRadius[0]
    # dropShadow 4, 0, 0, "#000000", 0.05