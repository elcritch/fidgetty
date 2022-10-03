import fidget_dev
import widgets
import behaviors/dragger

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

proc render*(
    props: SliderProps,
    self: SliderState,
): Events[All]=
  ## Draw a progress bars 
  gridTemplateRows csFixed(0.4'em) 1'fr csFixed(0.4'em)
  gridTemplateColumns csFixed(0.4'em) 1'fr csFixed(0.4'em)

  behavior self.dragger

  if props.label.len() > 0:
    text "text":
      gridArea 2 // 3, 2 // 3
      fill palette.text
      characters props.label

  rectangle "barFgTexture":
    gridArea 2 // 3, 2 // 3
    cornerRadius 0.80 * theme.cornerRadius[0]
    clipContent true

  rectangle "bar holder":
    gridArea 2 // 3, 2 // 3

    rectangle "pop button":
      let sliderPos = self.dragger.position(props.value)
      if sliderPos.updated:
        dispatchEvent changed(self.dragger.value)
    
      box sliderPos.value, 0, parent.box.h, parent.box.h
      fill palette.cursor
      cornerRadius theme
      stroke theme.outerStroke
      clipContent true
      imageOf theme.gloss

    rectangle "bar filling":
      # Draw the bar itself.
      let bw = (100.0 * props.value.clamp(0, 1.0)).csPerc()
      size bw, 100'pp
      fill palette.accent
      cornerRadius 0.80 * theme.cornerRadius[0]
      imageOf theme.gloss, 0.67
      clipContent true
      stroke theme.innerStroke

  rectangle "bar bg":
    gridArea 1 // 4, 1 // 4
    stroke theme.outerStroke
    fill palette.foreground
    cornerRadius 1.0 * theme.cornerRadius[0]

  cornerRadius 1.0 * theme.cornerRadius[0]