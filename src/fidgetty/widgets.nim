import macros, tables, strutils, strformat, math, random, options
import variant, patty
import std/macrocache

import macrohelpers

export tables, strformat, options
export math, random
export variant, patty

import fidget, theming
export fidget, theming

type
  WidgetProc* = proc()

template property*(name: untyped) {.pragma.}

const widgetArgsTable = CacheTable"fidgettyWidgetArgsTable "

# var widgetArgsTable* {.compileTime.} = initTable[string, seq[(string, string, NimNode, )]]()

macro widget*(widget, body: untyped): untyped =
  let procName = widget.strVal

  result = newStmtList()
  var attrs = initTable[string, NimNode]()
  for idx, attr in body.attributes():
    attrs[attr.name] = attr.code
  var args = newSeq[NimNode]()
  let widgetArgs = widgetArgsTable[procName].toWidgetArgs()
  
  result = newStmtList()
  for (argname, propname, argtype) in widgetArgs:
    if argtype.repr == "WidgetProc" and attrs.hasKey(propname):
      let pargname = genSym(nskLet, argname & "Arg")
      let code =
        if attrs.hasKey(propname): attrs[propname]
        else: nnkDiscardStmt.newTree(newEmptyNode())
      let pdecl = makeLambdaDecl(pargname, argtype, code)
      result.add pdecl
      args.add newNimNode(nnkExprEqExpr).
        add(ident(argname)).add(pargname)
    elif argtype.repr == "WidgetProc":
      args.add newNimNode(nnkExprEqExpr).
        add(ident(argname)).add(newNilLit())
    else:
      if not attrs.hasKey(propname):
        continue
      let code =
        if attrs.hasKey(propname): attrs[propname]
        else: newNilLit()
      args.add newNimNode(nnkExprEqExpr).
        add(ident(argname)).add(code)
  result.add newCall(`procName`, args)

proc makeWidgetPropertyMacro(procName, typeName: string): NimNode =
  let labelMacroName = ident typeName

  var labelMacroDef = quote do:
    template `labelMacroName`*(body: untyped) =
      Widget `procName`, body

  result = newStmtList()
  result.add labelMacroDef

proc eventsMacro*(tp: string, blks: TableRef[string, NimNode]): NimNode =
  result = newStmtList()
  let
    variantEvt = genSym(nskForVar, "evtVariant")
    evtName = genSym(nskLet, "evt")

  var matchBodies = newStmtList()
  for evtType, blk in blks:
    let body = nnkCommand.newTree(ident "match", evtName, blk)
    let et = ident(evtType)
    matchBodies.add quote do:
      if `variantEvt`.ofType(`et`):
        let `evtName` = `variantEvt`.get(`et`)
        `body`
  result.add quote do:
    var evts: seq[Variant]
    if not current.hookEvents.data.isNil and
           current.hookEvents.data.pop(current.code, evts):
      for `variantEvt` in evts:
        `matchBodies`


## ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
##             Widgets
## ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
## 
## These APIs provide the basic functionality for
## setting up layouts and constraingts. 
## 


proc makeStatefulWidget*(blk: NimNode, hasState, defaultState, wrapper: bool): NimNode =
  var
    procDef = blk
    body = procDef.body()
    params = procDef.params()
    pragmas = procDef.pragma()
    preBody = newStmtList()

  let
    hasEmptyReturnType = params[0].kind == nnkEmpty
    procName = procDef.name().strVal
    procNameCap = procName.capitalizeAscii()
    typeName =
      if not hasState: procNameCap & "Type"
      elif hasEmptyReturnType: procNameCap & "Type"
      else: params[0].strVal
    preName = ident("setup")
    postName = ident("post")
    identName = ident("id")

  if hasState and hasEmptyReturnType:
    warning("Fidgets with state should generally name their state typename using the return type. ", procDef)
  var
    initImpl: NimNode = newStmtList()
    renderImpl: NimNode
    evtName: string
    hasProperty = false
    onEventsImpl = newStmtList()
    onEventsBlocks = newTable[string, NimNode]()

  for idx, attr in body.attributes():
    body[idx] = newStmtList()
    case attr.name:
    of "init":
      initImpl = attr.code
    of "render":
      renderImpl = attr.code
    of "properties":
      if not hasState:
        error("'properties' requires a Stateful Fidget type. ", attr.code)
      hasProperty = true
      let wType = typeName.makeType(attr.code)
      preBody.add wType
    of "events":
      attr.code.expectKind(nnkStmtList)
      let evtIdent = attr.code[0]
      evtName = evtIdent.strVal
      let code = attr.code[1]
      let vp = nnkCommand.newTree(ident "variantp", evtIdent, code)
      preBody.add quote do:
        {.push hint[Name]: off.}
        `vp`
        {.pop.}
    of "onEvents":
      let evtIdent = attr.code[0]
      evtName = evtIdent.strVal
      let blk = attr.code[1]
      onEventsBlocks[evtName] = blk

  if onEventsBlocks.len() > 0:
    onEventsImpl = eventsMacro(evtName, onEventsBlocks)

  if not wrapper and renderImpl.isNil:
    error("fidgets must provide a render body!", procDef)

  var typeNameSym = ident(typeName)

  let stateSetup =
    if not hasState:
      newStmtList()
    else:
      if defaultState:
        quote do:
          useStateOverride(`typeNameSym`, self)
      else:
        quote do:
          if self == nil:
            raise newException(ValueError, "app widget state can't be nil")

  procDef.body = newStmtList()
  if wrapper:
    procDef.body.add body
  else:
    procDef.body.add quote do:
      component `identName`:
        let local {.inject, used.} = current
        `initImpl`
        `stateSetup`
        if `preName` != nil:
          `preName`()
        `onEventsImpl`
        `renderImpl`
        if `postName` != nil:
          `postName`()

  # handle return the Fidgets self state variables
  if hasState:
    params[0] = ident typeName
    if pragmas.kind == nnkEmpty:
      procDef.pragma = nnkPragma.newTree(ident("discardable"))
    else:
      procDef.pragma.add ident("discardable")
    procDef.body.add quote do:
      result = self

  # adjust Fidgets parameters, particularly add self, pre, post args. 
  let
    nilValue = quote do: nil
    preArg = newIdentDefs(preName, bindSym"WidgetProc", nilValue)
    postArg = newIdentDefs(ident("post"), bindSym"WidgetProc", nilValue)
    identArg = newIdentDefs(identName, bindSym"string",  newStrLitNode(procName))
  
  if hasState and hasProperty:
    let stateArg =
      if defaultState: newIdentDefs(ident("self"), ident(typeName), newNilLit())
      else:            newIdentDefs(ident("self"), ident(typeName))
    params.add stateArg
  params.add preArg
  params.add postArg 
  params.add identArg 

  var widgetArgs = newSeq[(string, string, NimNode)]()
  for idx, prop in params.propertyNames():
    echo fmt"PROPERTYNAMES: {prop.name=} {prop.label=} {prop.argtype.repr=}"
    let pname = if prop.label == "": prop.name else: prop.label
    widgetArgs.add( (prop.name, pname, prop.argtype,) )

  widgetArgsTable[procName] = widgetArgs.makeWidgetArgs()

  result = newStmtList()
  result.add preBody 
  result.add procDef

  if typeName != procNameCap:
    let pn = procName
    let pu = ident procNameCap
    result.add quote do:
      macro `pu`*(blk: untyped) =
        result = newCall("widget", ident `pn`, blk)

  
  if not hasState:
    result.add makeWidgetPropertyMacro(procName, typeName) 
  # echo "\n=== StatefulWidget === "
  # echo result.repr

macro basicFidget*(blk: untyped) =
  result = makeStatefulWidget(blk, hasState=false, defaultState=false, wrapper=false)

template useState*[T](tp: typedesc[T], name: untyped) =
  if current.hookStates.isEmpty():
    current.hookStates = newVariant(tp())
  var `name` {.inject.} = current.hookStates.get(tp)

template useStateOverride*[T](tp: typedesc[T], name: untyped) =
  if current.hookStates.isEmpty():
    current.hookStates = newVariant(tp())
  var `name` {.inject.} =
    if `name`.isNil:
      current.hookStates.get(tp)
    else:
      `name`

macro statefulFidget*(blk: untyped) =
  result = makeStatefulWidget(blk, hasState=true, defaultState=true, wrapper=false)

macro wrapperFidget*(blk: untyped) =
  result = makeStatefulWidget(blk, hasState=false, defaultState=false, wrapper=true)

macro appFidget*(blk: untyped) =
  result = makeStatefulWidget(blk, hasState=true, defaultState=true, wrapper=false)

macro reverseStmts*(body: untyped) =
  result = newStmtList()
  var stmts = newSeq[NimNode]()
  for ln in body:
    stmts.insert(ln, 0)
  result.add stmts

template Horizontal*(text, child: untyped) =
  group text:
    layout lmHorizontal
    counterAxisSizingMode csAuto
    constraints cMin, cStretch
    `child`

template Horizontal*(child: untyped) =
  Horizontal("", child)

template Vertical*(text, child: untyped) =
  group text:
    layout lmVertical
    counterAxisSizingMode csAuto
    constraints cMin, cStretch
    `child`

template Vertical*(child: untyped) =
  Vertical("", child)

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

template Spacer*(w, h: float32) =
  blank: size(w, h)

template Spacer*(s: float32) =
  Spacer(s, s)

template HSpacer*(h: float32) =
  blank: size(0, h)

template VSpacer*(w: float32) =
  blank: size(w, 0)

template wrapApp*(fidgetName: typed, fidgetType: typedesc): proc() =
  proc `fidgetName Main`() =
    useState(`fidgetType`, state)
    fidgetName(state)
  
  `fidgetName Main`
