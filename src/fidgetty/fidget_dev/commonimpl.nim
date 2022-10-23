import unicode
import typetraits
import variant, chroma, input
import options
import cssgrid

when not defined(js):
  import asyncfutures
  # import patches/textboxes 

import commonutils, common

type
  CapturedEvents = object
    mouse*: MouseCapture
    gesture*: GestureCapture

proc setupRoot*() =
  if root == nil:
    root = Node()
    root.kind = nkRoot
    root.id = atom"root"
    root.uid = newUId()
    root.zlevel = ZLevelDefault
    root.cursorColor = rgba(0, 0, 0, 255).color
  nodeStack = @[root]
  current = root
  root.diffIndex = 0

proc clearInputs*() =

  resetNodes = 0
  mouse.wheelDelta = 0
  mouse.consumed = false
  mouse.clickedOutside = false

  # Reset key and mouse press to default state
  for i in 0 ..< buttonPress.len:
    buttonPress[i] = false
    buttonRelease[i] = false

  if any(buttonDown, proc(b: bool): bool = b):
    keyboard.state = KeyState.Down
  else:
    keyboard.state = KeyState.Empty

const
  MouseButtons = [
    MOUSE_LEFT,
    MOUSE_RIGHT,
    MOUSE_MIDDLE,
    MOUSE_BACK,
    MOUSE_FORWARD
  ]

proc click*(mouse: Mouse): bool =
  for mbtn in MouseButtons:
    if buttonPress[mbtn]:
      return true

proc down*(mouse: Mouse): bool =
  for mbtn in MouseButtons:
    if buttonDown[mbtn]: return true

proc scrolled*(mouse: Mouse): bool =
  mouse.wheelDelta != 0.0

proc release*(mouse: Mouse): bool =
  for mbtn in MouseButtons:
    if buttonRelease[mbtn]: return true

proc consume*(keyboard: Keyboard) =
  ## Reset the keyboard state consuming any event information.
  keyboard.state = Empty
  keyboard.keyString = ""
  keyboard.altKey = false
  keyboard.ctrlKey = false
  keyboard.shiftKey = false
  keyboard.superKey = false
  keyboard.consumed = true

proc consume*(mouse: Mouse) =
  ## Reset the mouse state consuming any event information.
  buttonPress[MOUSE_LEFT] = false

proc setMousePos*(item: var Mouse, x, y: float64) =
  item.pos = vec2(x, y)
  item.pos *= pixelRatio / item.pixelScale
  item.delta = item.pos - item.prevPos
  item.prevPos = item.pos

proc mouseOverlapsNode*(node: Node): bool =
  ## Returns true if mouse overlaps the node node.
  let mpos = mouse.pos.descaled + node.totalOffset 
  let act = 
    (not popupActive or inPopup) and
    node.screenBox.w > 0'ui and
    node.screenBox.h > 0'ui 

  result =
    act and
    mpos.overlaps(node.screenBox) and
    (if inPopup: mouse.pos.descaled.overlaps(popupBox) else: true)

const
  MouseOnOutEvents = {evClickOut, evHoverOut, evOverlapped}

proc max[T](a, b: EventsCapture[T]): EventsCapture[T] =
  if b.zlvl >= a.zlvl and b.flags != {}: b else: a

template checkEvent[ET](evt: ET, predicate: typed) =
  when ET is MouseEventType:
    if evt in node.listens.mouse and predicate: result.incl(evt)
  elif ET is GestureEventType:
    if evt in node.listens.gesture and predicate: result.incl(evt)

proc checkMouseEvents*(node: Node): MouseEventFlags =
  ## Compute mouse events
  if node.mouseOverlapsNode():
    checkEvent(evClick, mouse.click())
    checkEvent(evPress, mouse.down())
    checkEvent(evRelease, mouse.release())
    checkEvent(evHover, true)
    checkEvent(evOverlapped, true)
  else:
    checkEvent(evClickOut, mouse.click())
    checkEvent(evHoverOut, true)

proc checkGestureEvents*(node: Node): GestureEventFlags =
  ## Compute gesture events
  if node.mouseOverlapsNode():
    checkEvent(evScroll, mouse.scrolled())

proc computeNodeEvents*(node: Node): CapturedEvents =
  ## Compute mouse events
  for n in node.nodes.reverse:
    let child = computeNodeEvents(n)
    result.mouse = max(result.mouse, child.mouse)
    result.gesture = max(result.gesture, child.gesture)

  let
    allMouseEvts = node.checkMouseEvents()
    mouseOutEvts = allMouseEvts * MouseOnOutEvents
    mouseEvts = allMouseEvts - MouseOnOutEvents
    gestureEvts = node.checkGestureEvents()

  # set on-out events 
  node.events.mouse.incl(mouseOutEvts)

  let
    captured = CapturedEvents(
      mouse: MouseCapture(zlvl: node.zlevel, flags: mouseEvts, target: node),
      gesture: GestureCapture(zlvl: node.zlevel, flags: gestureEvts, target: node)
    )

  if node.clipContent and not node.mouseOverlapsNode():
    # this node clips events, so it must overlap child events, 
    # e.g. ignore child captures if this node isn't also overlapping 
    result = captured
  else:
    result.mouse = max(captured.mouse, result.mouse)
    result.gesture = max(captured.gesture, result.gesture)
  

proc computeEvents*(node: Node) =
  let res = computeNodeEvents(node)
  template handleCapture(name, field, ignore: untyped) =
    ## process event capture
    if not res.`field`.target.isNil:
      let evts = res.`field`
      let target = evts.target
      target.events.`field` = evts.flags
      if target.kind != nkRoot and evts.flags - ignore != {}:
        # echo "EVT: ", target.kind, " => ", evts.flags, " @ ", target.id
        requestedFrame = 2
  ## mouse and gesture are handled separately as they can have separate
  ## node targets
  handleCapture("mouse", mouse, {evHover})
  handleCapture("gesture", gesture, {})

var gridChildren: seq[Node]

template calcBasicConstraintImpl(
    parent, node: Node,
    dir: static GridDir,
    f: untyped
) =
  ## computes basic constraints for box'es when set
  ## this let's the use do things like set 90'pp (90 percent)
  ## of the box width post css grid or auto constraints layout
  template calcBasic(val: untyped): untyped =
    block:
      var res: UICoord
      match val:
        UiFixed(coord):
          res = coord.UICoord
        UiFrac(frac):
          res = frac.UICoord * parent.box.f
        UiPerc(perc):
          let ppval = when astToStr(f) == "x": parent.box.w
                      elif astToStr(f) == "y": parent.box.h
                      else: parent.box.f
          res = perc.UICoord / 100.0.UICoord * ppval
      res
  
  let csValue = when astToStr(f) in ["w", "h"]: node.cxSize[dir] 
                else: node.cxOffset[dir]
  match csValue:
    UiAuto():
      when astToStr(f) in ["w", "h"]:
        node.box.f = parent.box.f
      else:
        discard
    UiSum(ls, rs):
      let lv = ls.calcBasic()
      let rv = rs.calcBasic()
      node.box.f = lv + rv
    UiMin(ls, rs):
      let lv = ls.calcBasic()
      let rv = rs.calcBasic()
      node.box.f = min(lv, rv)
    UiMax(ls, rs):
      let lv = ls.calcBasic()
      let rv = rs.calcBasic()
      node.box.f = max(lv, rv)
    UiValue(value):
      node.box.f = calcBasic(value)
    _:
      discard

proc calcBasicConstraint(parent, node: Node, dir: static GridDir, isXY: static bool) =
  when isXY == true and dir == dcol: 
    calcBasicConstraintImpl(parent, node, dir, x)
  elif isXY == true and dir == drow: 
    calcBasicConstraintImpl(parent, node, dir, y)
  elif isXY == false and dir == dcol: 
    calcBasicConstraintImpl(parent, node, dir, w)
  elif isXY == false and dir == drow: 
    calcBasicConstraintImpl(parent, node, dir, h)

proc computeLayout*(parent, node: Node) =
  ## Computes constraints and auto-layout.
  
  # simple constraints
  if node.gridItem.isNil:
    calcBasicConstraint(parent, node, dcol, true)
    calcBasicConstraint(parent, node, drow, true)
    calcBasicConstraint(parent, node, dcol, false)
    calcBasicConstraint(parent, node, drow, false)

  # css grid impl
  if not node.gridTemplate.isNil:
    
    gridChildren.setLen(0)
    for n in node.nodes:
      if n.layoutAlign != laIgnore:
        gridChildren.add(n)
    node.gridTemplate.computeNodeLayout(node, gridChildren)

    for n in node.nodes:
      computeLayout(node, n)
    
    return

  for n in node.nodes:
    computeLayout(node, n)

  if node.layoutAlign == laIgnore:
    return

  # Constraints code.
  case node.constraintsVertical:
    of cMin: discard
    of cMax:
      let rightSpace = parent.orgBox.w - node.box.x
      # echo "rightSpace : ", rightSpace  
      node.box.x = parent.box.w - rightSpace
    of cScale:
      let xScale = parent.box.w / parent.orgBox.w
      # echo "xScale: ", xScale 
      node.box.x *= xScale
      node.box.w *= xScale
    of cStretch:
      let xDiff = parent.box.w - parent.orgBox.w
      # echo "xDiff: ", xDiff   
      node.box.w += xDiff
    of cCenter:
      let offset = floor((node.orgBox.w - parent.orgBox.w) / 2.0'ui + node.orgBox.x)
      # echo "offset: ", offset   
      node.box.x = floor((parent.box.w - node.box.w) / 2.0'ui) + offset

  case node.constraintsHorizontal:
    of cMin: discard
    of cMax:
      let bottomSpace = parent.orgBox.h - node.box.y
      # echo "bottomSpace  : ", bottomSpace   
      node.box.y = parent.box.h - bottomSpace
    of cScale:
      let yScale = parent.box.h / parent.orgBox.h
      # echo "yScale: ", yScale
      node.box.y *= yScale
      node.box.h *= yScale
    of cStretch:
      let yDiff = parent.box.h - parent.orgBox.h
      # echo "yDiff: ", yDiff 
      node.box.h += yDiff
    of cCenter:
      let offset = floor((node.orgBox.h - parent.orgBox.h) / 2.0'ui + node.orgBox.y)
      node.box.y = floor((parent.box.h - node.box.h) / 2.0'ui) + offset

  # Typeset text
  if node.kind == nkText:
    computeTextLayout(node)
    case node.textStyle.autoResize:
      of tsNone:
        # Fixed sized text node.
        discard
      of tsHeight:
        # Text will grow down.
        node.box.h = node.textLayoutHeight
      of tsWidthAndHeight:
        # Text will grow down and wide.
        node.box.w = node.textLayoutWidth
        node.box.h = node.textLayoutHeight
    # print "layout:nkText: ", node.id, node.box

  template compAutoLayoutNorm(field, fieldSz, padding: untyped;
                              orth, orthSz, orthPadding: untyped) =
    # echo "layoutMode : ", node.layoutMode 
    if node.counterAxisSizingMode == csAuto:
      # Resize to fit elements tightly.
      var maxOrth = 0.0'ui
      for n in node.nodes:
        if n.layoutAlign != laStretch:
          maxOrth = max(maxOrth, n.box.`orthSz`)
      node.box.`orthSz` = maxOrth  + node.`orthPadding` * 2'ui

    var at = 0.0'ui
    at += node.`padding`
    for i, n in node.nodes.pairs:
      if n.layoutAlign == laIgnore:
        continue
      if i > 0:
        at += node.itemSpacing

      n.box.`field` = at

      case n.layoutAlign:
        of laMin:
          n.box.`orth` = node.`orthPadding`
        of laCenter:
          n.box.`orth` = node.box.`orthSz`/2'ui - n.box.`orthSz`/2'ui
        of laMax:
          n.box.`orth` = node.box.`orthSz` - n.box.`orthSz` - node.`orthPadding`
        of laStretch:
          n.box.`orth` = node.`orthPadding`
          n.box.`orthSz` = node.box.`orthSz` - node.`orthPadding` * 2'ui
          # Redo the layout for child node.
          computeLayout(node, n)
        of laIgnore:
          continue
      at += n.box.`fieldSz`
    at += node.`padding`
    node.box.`fieldSz` = at

  # Auto-layout code.
  if node.layoutMode == lmVertical:
    compAutoLayoutNorm(y, h, verticalPadding, x, w, horizontalPadding)

  if node.layoutMode == lmHorizontal:
    # echo "layoutMode : ", node.layoutMode 
    compAutoLayoutNorm(x, w, horizontalPadding, y, h, verticalPadding)

proc computeScreenBox*(parent, node: Node) =
  ## Setups screenBoxes for the whole tree.
  if parent == nil:
    node.screenBox = node.box
    node.totalOffset = node.offset
  else:
    node.screenBox = node.box + parent.screenBox
    node.totalOffset = node.offset + parent.totalOffset
  for n in node.nodes:
    computeScreenBox(node, n)

proc atXY*[T: Box](rect: T, x, y: int | float32 | UICoord): T =
  result = rect
  result.x = UICoord(x)
  result.y = UICoord(y)
proc atXY*[T: Rect](rect: T, x, y: int | float32): T =
  result = rect
  result.x = x
  result.y = y

proc `+`*(rect: Rect, xy: Vec2): Rect =
  ## offset rect with xy vec2 
  result = rect
  result.x += xy.x
  result.y += xy.y

proc `~=`*(rect: Vec2, val: float32): bool =
  result = rect.x ~= val and rect.y ~= val


import std/macrocache
const mcStateCounter = CacheCounter"stateCounter"

template useStateImpl*[T: ref](node: Node, vname: untyped) =
  ## creates and caches a new state ref object
  const id = static:
    hash(astToStr(vname))
  if not node.userStates.hasKey(id):
    node.userStates[id] = newVariant(T.new())
  var `vname` {.inject.} = node.userStates[id].get(typeof T)

template withStateImpl*[T: ref](tp: typedesc[T]): untyped =
  ## creates and caches a new state ref object
  block:
    const id = 
      static:
        mcStateCounter.inc(1)
        value(mcStateCounter)

    if not current.userStates.hasKey(id):
      current.userStates[id] = newVariant(tp.new())
    current.userStates[id].get(tp)
