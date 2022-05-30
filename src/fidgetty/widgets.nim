import macros, tables, strutils, strformat, math, random, options
import bumpy, variant, patty

export tables, strutils, strformat, options
export bumpy, math, random
export bumpy, variant, patty

import fidget, theming
export fidget, theming

type
  WidgetProc* = proc()

template property*(name: untyped) {.pragma.}


proc makeLambdaDecl*(
    pargname: NimNode,
    argtype: NimNode,
    code: NimNode,
): NimNode =
  result = nnkLetSection.newTree(
    nnkIdentDefs.newTree(
      pargname,
      argtype,
      nnkLambda.newTree(
        newEmptyNode(),
        newEmptyNode(),
        newEmptyNode(),
        nnkFormalParams.newTree(newEmptyNode()),
        newEmptyNode(),
        newEmptyNode(),
        code,
      )
    )
  )

iterator attributes*(blk: NimNode): (int, string, NimNode) =
  for idx, item in blk:
    if item.kind == nnkCall:
      var name = item[0].repr
      if item.len() > 2:
        let code = newStmtList(item[1..^1])
        yield (idx, name, code)
      else:
        yield (idx, name, item[1])

iterator propertyNames*(params: NimNode): (int, string, string, NimNode) =
  for idx, item in params:
    if item.kind == nnkEmpty:
      continue
    elif item.kind == nnkIdentDefs and item[0].kind == nnkPragmaExpr:
      var name = item[0][0].repr
      var pname = item[0][1][0][1].strVal
      var code = item[1]
      yield (idx, name, pname, code)
    elif item.kind == nnkIdentDefs and item[0].kind == nnkIdent:
      var name = item[0].repr
      var code = item[1]
      yield (idx, name, "", code)

proc makeType(name: string, body: NimNode): NimNode =
  var propDefs = newTable[string, NimNode]()
  var propTypes = newTable[string, NimNode]()

  for prop in body:
    if prop.kind == nnkCommentStmt:
      continue # skip comment
    prop.expectKind(nnkCall)
    prop[0].expectKind(nnkIdent)

    let pname = prop[0].strVal
    let pHasDefault = prop[1][0].kind == nnkAsgn
    if pHasDefault:
      propTypes[pname] = prop[1][0][0]
      propDefs[pname] = prop[1][0][1]
    else:
      propTypes[pname] = prop[1][0]
  
  result = newStmtList()
  let tpName = ident(name)
  var tp = quote do:
    type `tpName`* = ref object
      a: int
  var rec = newNimNode(nnkRecList)
  for pd, pv in propTypes:
    let pdfield = nnkPostfix.newTree(ident("*"), ident(pd)) 
    rec.add newIdentDefs(pdfield, pv)
  tp[0][^1][0][^1] = rec
  result.add tp

var widgetArgsTable* {.compileTime.} = initTable[string, seq[(string, string, NimNode, )]]()

macro widget*(widget, body: untyped): untyped =
  let procName = widget.strVal

  result = newStmtList()
  var attrs = initTable[string, NimNode]()
  for idx, name, code in body.attributes():
    attrs[name] = code
  var args = newSeq[NimNode]()
  let widgetArgs = widgetArgsTable[procName]
  
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

  for idx, name, code in body.attributes():
    body[idx] = newStmtList()
    case name:
    of "init":
      initImpl = code
    of "render":
      renderImpl = code
    of "properties":
      if not hasState:
        error("'properties' requires a Stateful Fidget type. ", code)
      hasProperty = true
      let wType = typeName.makeType(code)
      preBody.add wType
    of "events":
      code.expectKind(nnkStmtList)
      let evtIdent = code[0]
      evtName = evtIdent.strVal
      let code = code[1]
      let vp = nnkCommand.newTree(ident "variantp", evtIdent, code)
      preBody.add quote do:
        {.push hint[Name]: off.}
        `vp`
        {.pop.}
    of "onEvents":
      let evtIdent = code[0]
      evtName = evtIdent.strVal
      let blk = code[1]
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
  for idx, argname, propname, argtype in params.propertyNames():
    let pname = if propname == "": argname else: propname
    widgetArgs.add( (argname, pname, argtype,) )

  widgetArgsTable[procName] = widgetArgs

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

template horizontal*(text, child: untyped) =
  group text:
    layout lmHorizontal
    counterAxisSizingMode csAuto
    constraints cMin, cStretch
    `child`

template horizontal*(child: untyped) =
  horizontal("", child)

template Horizontal*(text, child: untyped) =
  group text:
    layout lmHorizontal
    counterAxisSizingMode csAuto
    constraints cMin, cStretch
    `child`

template Horizontal*(child: untyped) =
  horizontal("", child)

template vertical*(text, child: untyped) =
  group text:
    layout lmVertical
    counterAxisSizingMode csAuto
    constraints cMin, cStretch
    `child`

template vertical*(child: untyped) =
  vertical("", child)

template Vertical*(text, child: untyped) =
  group text:
    layout lmVertical
    counterAxisSizingMode csAuto
    constraints cMin, cStretch
    `child`

template Vertical*(child: untyped) =
  vertical("", child)

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

template spacer*(w, h: float32) =
  blank: size(w, h)

template spacer*(s: float32) =
  spacer(s, s)

template wrapApp*(fidgetName: typed, fidgetType: typedesc): proc() =
  proc `fidgetName Main`() =
    useState(`fidgetType`, state)
    fidgetName(state)
  
  `fidgetName Main`
