import fidget_dev
import widgets
import behaviors/dragger
import button

fidgetty Slider:
  properties:
    value: float
    label: string
  state:
    dragger: Dragger

proc new*(_: typedesc[SliderProps]): SliderProps =
  new result
  size 100'pp, 2.Em
  # textAutoResize tsHeight
  # layoutAlign laStretch
  stroke theme.outerStroke

proc preRender*(
    props: SliderProps,
    self: SliderState,
) =
  # Setup CSS Grid Template
  gridTemplateRows csFixed(0.4'em) 1'fr csFixed(0.4'em)
  gridTemplateColumns csFixed(0.4'em) 1'fr csFixed(0.4'em)

proc render*(
    props: SliderProps,
    self: SliderState,
): Events[All]=
  ## Draw a progress bars 

  behavior self.dragger

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

    rectangle "button":
      themeExtra atom"pop"
      let sliderPos = self.dragger.position(props.value)
      if sliderPos.updated:
        dispatchEvent changed(self.dragger.value)
    
      box sliderPos.value, 0, parent.box.h, parent.box.h

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