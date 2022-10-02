import std/[macros, tables, strutils, strformat, math, random, options]
import std/macrocache
import variant, patty

import macrohelpers

export tables, strformat, options
export math, random
export variant, patty

import fidget_dev, theming
export fidget_dev, theming, tables

type
  WidgetProc* = proc()


## ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
##             Widgets
## ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
## 
## These APIs provide the basic functionality for
## setting up layouts and constraingts. 
## 

type
  WidgetArgs* = concept w
    w is ref
    ($typeof(w)).endswith("Args")
  
  WidgetState* = concept w
    w is ref
    ($typeof(w)).endswith("State")

proc matchEventsImpl(code: NimNode): NimNode =
  let hasOther = code.mapIt(it[0].repr).anyIt(it == "_")
  if not hasOther:
    code.add nnkCommand.newTree(
      ident "_",
      nnkDiscardStmt.newTree(nnkEmpty.newNimNode()),
    )
  result = nnkCommand.newTree(
    ident "match",
    ident "evt",
    code
  )

proc processEventsImpl(tp, body: NimNode): NimNode =
  let code = body
  let match = matchEventsImpl(code)
  result = quote do:
    var evts: seq[`tp`]
    {.push warning[UnreachableElse]: off.}
    if events.popEvents(evts):
      for evt {.inject.} in evts:
        `match`
    {.pop.}
  # echo "res: ", result.treeRepr

macro doBlocks*(blks: varargs[untyped]) =
  # echo "DOEVENTS: ", blks.treeRepr
  result = newStmtList()
  if blks.len() == 0:
    return
  for blk in blks:
    if blk.kind == nnkDo:
      let arg = blk.params[0]
      let body = blk.body
      # arg.expectKind nnkIdent
      result = processEventsImpl(arg, body)
    elif blk.kind == nnkFinally:
      result.add blk[0]

macro fidgetty*(name, blk: untyped) =
  # echo "BLK: ", treeRepr blk
  let
    procName = name.strVal.capitalizeAscii()
    propsTypeName = procName & "Props"
    stateTypeName = procName & "State"

  var setters: NimNode
  result = newStmtList()
  for idx, attr in blk.attributes():
    case attr.name:
    of "properties":
      let wType = propsTypeName.makeType(attr.code)
      # echo "WTYPE:arg: ", repr wType
      setters = makeSetters("test", attr.code)
      result.add wType
    of "state":
      let wType = stateTypeName.makeType(attr.code)
      # echo "WTYPE:prop: ", repr wType
      result.add wType
  
  let
    procId = ident procName
    propsTypeId = ident propsTypeName
    stateTypeId = ident stateTypeName
  
  result.add quote do:
    template `procId`*(code: untyped, handlers: varargs[untyped]) =
      # printRepr(handlers)
      block:
        component `procName`:
          useState[`propsTypeId`](item)
          useState[`stateTypeId`](state)
          var events {.inject, used.}: Events
          `setters`
          code
          events = item.render(state)
          doBlocks(handlers)
  # echo "result:\n", repr result

variants ValueChange:
  ## variant case types for scroll events
  Index(index: int)
  Bool(bval: bool)
  Float(fval: float)
  Strings(sval: string)

macro processEvents*(tp, body: untyped): untyped =
  result = processEventsImpl(tp, body)

template forEvents*(evts, body: untyped): untyped =
  var evts: seq[`tp`]
  {.push warning[UnreachableElse]: off.}
  for event {.inject.} in evts:
    `match`
  {.pop.}

template dispatchMouseEvents*(): untyped =
  for evt in current.events.mouse:
    dispatchEvent MouseEvent(kind: evt)

macro reverseStmts*(body: untyped) =
  result = newStmtList()
  var stmts = newSeq[NimNode]()
  for ln in body:
    stmts.insert(ln, 0)
  result.add stmts

# =========================
template Box*(text, child: untyped) =
  group text:
    layout parent.layoutMode
    counterAxisSizingMode parent.counterAxisSizingMode
    `child`

template Box*(child: untyped) =
  Box("", child)

template Horizontal*(text, child: untyped) =
  group text:
    layout lmHorizontal
    counterAxisSizingMode csAuto
    `child`

template Horizontal*(child: untyped) =
  Horizontal("", child)

template Vertical*(text, child: untyped) =
  group text:
    layout lmVertical
    counterAxisSizingMode csAuto
    `child`

template Vertical*(child: untyped) =
  Vertical("", child)

template Group*(child: untyped) =
  group text:
    `child`

template Centered*(child: untyped) =
  Horizontal: # "centered":
    centeredX current.screenBox.w
    centeredY current.screenBox.h
    `child`


template VHBox*(sz, child: untyped) =
  Vertical:
    sz
    Horizontal:
      child

template Theme*(pl: Palette, child: untyped) =
  block:
    push pl
    `child`
    pop(Palette)

template ThemePalette*(child: untyped) =
  block:
    var pl = palette()
    push pl
    `child`
    pop(Palette)

template GeneralTheme*(child: untyped) =
  block:
    var th = theme()
    push th
    `child`
    pop(GeneralTheme)

template Spacer*(w: UICoord, h: UICoord) =
  blank: size(w, h)

template VSpacer*(h: UICoord) =
  blank: size(0, h)

template HSpacer*(w: UICoord) =
  blank: size(w, 0)

template wrapApp*(fidgetName: typed, fidgetType: typedesc): proc() =
  proc `fidgetName Main`() =
    useState[`fidgetType`](state)
    fidgetName(state)
  
  `fidgetName Main`
