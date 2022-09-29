import fidget_dev
import widgets

type
  Dragger* = ref object
    isDrag*: bool
    value*: float32
    prev*: float32

proc activate*(self: Dragger, isActive = true) =
  self.isDrag = isActive

proc active*(self: Dragger): bool =
  self.isDrag

template setup*(dragger: Dragger) =
  if dragger.isNil:
    dragger.new()
  
  onClick:
    dragger.activate()
  
  if dragger.active():
    dragger.activate(buttonDown[MOUSE_LEFT])

proc position*(self: Dragger, value: float32): tuple[value: UICoord, updated: bool] =
  let popBtnWidth = height()
  let popTrackWidth = width() - popBtnWidth
  if self.isDrag:
    let rel = current.mouseRatio(pad=popBtnWidth, clamped=true)
    self.value = rel.x.float32
    if value != self.value:
      result[1] = true
    # if value != self.value:
    #   result[0] = dispatchEvent Float(self.value)

  let pipFrac = UICoord(value).clamp(0'ui, 1'ui)
  let pipPos = popTrackWidth*pipFrac
  result[0] = pipPos
