import std/[macros, tables, strutils, strformat, math, random, options]
import std/macrocache
import variant, patty

import macrohelpers

export tables, strformat, options
export math, random
export variant, patty

import fidget_dev, extras, events
export fidget_dev, extras, events, tables

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

template to*[V, T](events: Events[T], v: typedesc[V]): Events[V] =
  Events[V](events)

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

macro processEvents*(tp, body: untyped): untyped =
  result = processEventsImpl(tp, body)

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
    simpleName = name.strVal.toLowerAscii()
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
        component `simpleName`:
          useState[`propsTypeId`](item)
          useState[`stateTypeId`](state)
          item.preRender(state)
          var events {.inject, used.}: Events[All]
          `setters`
          code
          events = item.render(state).to(All)
          doBlocks(handlers)
  # echo "result:\n", repr result

template dispatchMouseEvents*(): untyped =
  for evt in current.events.mouse:
    dispatchEvent MouseEvent(kind: evt)

macro reverseStmts*(body: untyped) =
  result = newStmtList()
  var stmts = newSeq[NimNode]()
  for ln in body:
    stmts.insert(ln, 0)
  result.add stmts

proc preRender*[T, V](t: T, v: V) =
  discard
