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
  box 0, 0, 100'pp, 2.Em
  # textAutoResize tsHeight
  # layoutAlign laStretch
  stroke theme.outerStroke

proc preRender*(
    props: ProgressBarProps,
    self: ProgressBarState,
) =
  # Setup CSS Grid Template
  gridTemplateRows csFixed(0.4'em) 1'fr csFixed(0.4'em)
  gridTemplateColumns csFixed(0.4'em) 1'fr csFixed(0.4'em)

proc render*(
    props: ProgressBarProps,
    self: ProgressBarState,
): Events =
  ## Draw a progress bars 

  if props.label.len() > 0:
    text "text":
      gridArea 2 // 3, 2 // 3
      fill theme.text
      characters props.label

  rectangle "barFgTexture":
    gridArea 2 // 3, 2 // 3
    cornerRadius 0.80 * theme.cornerRadius[0]
    clipContent true

  rectangle "bar":
    gridArea 2 // 3, 2 // 3
    rectangle "filling":
      # Draw the bar itself.
      let bw = (100.0 * props.value.clamp(0, 1.0)).csPerc()
      size bw, 100'pp

  rectangle "bar-gloss":
    gridArea 1 // 4, 1 // 4
    stroke theme.outerStroke
    fill theme.foreground
    cornerRadius 1.0 * theme.cornerRadius[0]

  cornerRadius 1.0 * theme.cornerRadius[0]