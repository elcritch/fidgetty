import widgets
import button

# var framecount = 0

fidgetty Listbox:
  properties:
    items: seq[string]
    selected: int
    itemsVisible: int
    triggers: Events
  state:
    showScrollBars: bool

proc new*(_: typedesc[ListboxProps]): ListboxProps =
  new result
  size 8'em, 1.5'em
  cornerRadius theme.cornerRadius
  stroke theme.outerStroke
  image theme.gloss

proc render*(
    props: ListboxProps,
    self:  ListboxState
): Events =
  ## listbox widget 
  let events = props.triggers

  var
    scrollAmount = 0.0'f32
    wasScrolled = false

  processEvents(ScrollEvent):
    ScrollTo(perc: nperc):
      scrollAmount = nperc
      wasScrolled = true
    ScrollPage(amount: amount):
      scrollAmount = amount
      wasScrolled = true

  let
    cb = current.box
    bw = cb.w
    bh = cb.h
    bih = bh.float32 * 1.0

  let
    bdh = min(bih * props.itemsVisible.float32, windowLogicalSize.y/2)

  # let evts = useEvents()
  # let evtCode = current.code
  # echo fmt"event code: {current.code} {evts.data.keys().toSeq().repr}"

  box 0, bh, bw, bdh
  clipContent true

  group "menuoutline":
    box 0, 0, bw, bdh
    cornerRadius theme.cornerRadius
    stroke theme.outerStroke

  inPopup = true
  defer: inPopup = false
  popupBox = current.screenBox

  group "menu":
    box 0, 0, bw, bdh
    layout lmVertical
    counterAxisSizingMode CounterAxisSizingMode.csAuto
    itemSpacing theme.itemSpacing
    scrollpane true

    if wasScrolled:
      current.offset.y =
        (current.screenBox.h - parent.screenBox.h) * scrollAmount.UICoord

    for idx, buttonName in pairs(props.items):
      group "menu":
        box 0, 0, bw, bih
        layoutAlign laCenter
        # echo fmt"{idx=} => {isCovered(popupBox)=}"

        Button:
          clearShadows()
          imageTransparency 0.1
          boxOf parent
          cornerRadius 0
          stroke theme.innerStroke

          label buttonName
          isActive idx == props.selected
          onClick:
            dispatchEvent changed(idx)
