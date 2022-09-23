import widgets

fidgetty Slider:
  properties:
    value: float
    label: string
    disabled: bool

  ## Draw a progress bars 
  state:
    pipDrag: bool
    pipValue: float
    value: float

proc new*(_: typedesc[SliderProps]): SliderProps =
  new result
  size 100'pp, 2'em
  cornerRadius theme

proc render*(
    props: SliderProps,
    self: SliderState
): Events =
  ## Draw a progress bars 
  gridTemplateRows csFixed(0.4'em) 1'fr csFixed(0.4'em)
  gridTemplateColumns csFixed(0.4'em) 1'fr csFixed(0.4'em)

  onClick:
    self.pipDrag = true

  if self.pipDrag:
    self.pipDrag = buttonDown[MOUSE_LEFT]
  
  text "text":
    gridArea 2 // 3, 2 // 3
    fill palette.text
    characters props.label
  rectangle "bar holder":
    gridArea 2 // 3, 2 // 3

    let popBtnWidth = height()
    let popTrackWidth = width() - popBtnWidth
    if self.pipDrag:
      let rel = current.mouseRatio(pad=popBtnWidth, clamped=true)
      self.value = rel.x.float32
      if props.value != self.value:
        dispatchEvent Float(self.value)

    let pipFrac = UICoord(props.value).clamp(0'ui, 1'ui)
    let pipPos = popTrackWidth*pipFrac

    rectangle "pop button":
      box pipPos, 0, parent.box.h, parent.box.h
      fill palette.cursor
      cornerRadius theme
      stroke theme.outerStroke
      clipContent true
      imageOf theme.gloss

    rectangle "bar holder":
      box 0, 0, pipPos + parent.box.h/2, parent.box.h
      fill palette.accent
      cornerRadius theme
      clipContent true
      imageOf theme.gloss, 0.77

  rectangle "bar bg":
    gridArea 1 // 4, 1 // 4
    imageOf theme.gloss
    rotation 180
    fill palette.foreground
    cornerRadius theme
    clipContent true
    stroke theme.outerStroke