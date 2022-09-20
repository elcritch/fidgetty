import fidget_dev
import widgets

fidgetty ProgressBar:
  properties:
    value: float
    label: string
  state:
    empty: void

proc new*(_: typedesc[ProgressBarProps]): ProgressBarProps =
  new result
  box 0, 0, 100.WPerc, 2.Em
  textAutoResize tsHeight
  layoutAlign laStretch
  stroke theme.outerStroke

proc render*(
    props: ProgressBarProps,
    self: ProgressBarState,
): Events =
  ## Draw a progress bars 

  gridTemplateRows csFixed(0.4'em) 1'fr csFixed(0.4'em)
  gridTemplateColumns csFixed(0.4'em) 1'fr csFixed(0.4'em)

  let
    cbarW = (100.0 * props.value.clamp(0, 1.0)).csPerc()

  if props.label.len() > 0:
    text "text":
      gridRow 2 // 3
      gridColumn 2 // 3
      fill palette.text
      characters props.label

  rectangle "barFgTexture":
    gridRow 2 // 3
    gridColumn 2 // 3
    cornerRadius 0.80 * theme.cornerRadius[0]
    clipContent true

  rectangle "bar holder":
    gridRow 2 // 3
    gridColumn 2 // 3
    rectangle "bar":
      # Draw the bar itself.
      size cbarW, 100'pp
      fill palette.accent
      cornerRadius 0.80 * theme.cornerRadius[0]
      imageOf theme.gloss, 0.67
      clipContent true
      stroke theme.innerStroke

  rectangle "bar bg":
    gridRow 1 // 4
    gridColumn 1 // 4
    stroke theme.outerStroke
    fill palette.foreground
    cornerRadius 1.0 * theme.cornerRadius[0]

  cornerRadius 1.0 * theme.cornerRadius[0]