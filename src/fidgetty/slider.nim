import std/strformat

import widgets
import print

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
  # box 0, 0, 100'pp, 2.Em
  # textAutoResize tsHeight
  # layoutAlign laStretch
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
    echo "pipDrag: ", self.pipDrag 
  
  text "text":
    # box 0, 0, bw, bh
    gridArea 2 // 3, 2 // 3
    fill palette.text
    characters props.label
  rectangle "bar holder":
    gridArea 2 // 3, 2 // 3
    # box barOuter, barOuter, pipPos+bh/2, bh-barOuter*2
    fill palette.accent
    cornerRadius theme
    clipContent true
    imageOf theme.gloss, 0.77

    let popBtnWidth = height()
    let popTrackWidth = width() - popBtnWidth
    if self.pipDrag:
      let pos = (mouseRelative().x - popBtnWidth/2.0)/popTrackWidth 
      self.value = pos.float32.clamp(0.0, 1.0)
      print self.value, pos, mouseRelative()
      if props.value != self.value:
        dispatchEvent Float(self.value)

    rectangle "pop button":
      let pipPos =
          UICoord(popTrackWidth.float32*clamp(props.value, 0, 1.0))

      # echo "pipPos: ", pipPos
      box pipPos, 0, parent.box.h, parent.box.h
      fill palette.cursor
      cornerRadius theme
      stroke theme.outerStroke
      clipContent true
      imageOf theme.gloss

  rectangle "bar bg":
    gridArea 1 // 4, 1 // 4
    imageOf theme.gloss
    rotation 180
    fill palette.foreground
    cornerRadius theme
    clipContent true
    stroke theme.outerStroke