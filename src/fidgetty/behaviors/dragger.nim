import ../fidget_dev

type
  Dragger* = ref object
    isDrag*: bool
    value*: float32
    prev*: float32

proc activate*(self: Dragger, isActive = true) =
  self.isDrag = isActive

proc active*(self: Dragger): bool =
  self.isDrag

template behavior*(dragger: Dragger) =
  if dragger.isNil:
    dragger.new()
  
  onClick:
    dragger.activate()
  
  if dragger.active():
    dragger.activate(buttonDown[MOUSE_LEFT])

proc position*(self: Dragger, value: float32, size = height(), node = common.parent, normalized=false): tuple[value: UICoord, updated: bool] =
  let popTrackWidth = node.box.w - size
  if self.isDrag:
    let rel = node.mouseRatio(pad=size, clamped=true)
    self.value = rel.x.float32
    if value != self.value:
      result[1] = true

  let pipFrac = UICoord(value).clamp(0'ui, 1'ui)
  if normalized:
    result[0] = pipFrac
  else:
    let pipPos = popTrackWidth*pipFrac
    result[0] = pipPos

template draggable*(enable: bool): untyped =
  ## enable slider dragging
  if enable:
    behavior state.dragger

    let sliderPos = state.dragger.position(
      state.dragger.value,
      0'ui,
      node = parent,
      normalized=true
    )
    # print sliderPos
    if sliderPos.updated:
      # sliderFraction state.dragger.value
      refresh()