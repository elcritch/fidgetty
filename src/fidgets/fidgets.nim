import macros, tables, strutils, strformat

import fidget/common

type
  WidgetProc* = proc()

template property*(name: untyped) {.pragma.}

proc makeLambdaDecl(
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
    # echo "ATTRNAMES: KIND: ", item.kind
    # echo "ATTRNAMES: ", item.treeRepr
    if item.kind == nnkCall:
      var name = item[0].repr
      if item.len() > 2:
        let code = newStmtList(item[1..^1])
        yield (idx, name, code)
      else:
        yield (idx, name, item[1])

iterator propertyNames*(params: NimNode): (int, string, string, NimNode) =
  for idx, item in params:
    # echo "PROPERTYNAMES: KIND: ", item.kind
    # echo "PROPERTYNAMES: ", item.treeRepr
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
  # echo "\nprops: "
  var propDefs = newTable[string, NimNode]()
  var propTypes = newTable[string, NimNode]()

  for prop in body:
    if prop.kind == nnkCommentStmt:
      continue # skip comment
    prop.expectKind(nnkCall)
    prop[0].expectKind(nnkIdent)
    # echo "prop: ", treeRepr prop
    let pname = prop[0].strVal
    let pHasDefault = prop[1][0].kind == nnkAsgn
    if pHasDefault:
      propTypes[pname] = prop[1][0][0]
      propDefs[pname] = prop[1][0][1]
    else:
      propTypes[pname] = prop[1][0]
  
  # echo "propTypes: "
  result = newStmtList()
  let tpName = ident(name)
  var tp = quote do:
    type `tpName`* = ref object
      a: int
  var rec = newNimNode(nnkRecList)
  for pd, pv in propTypes:
    # echo "pd: ", pd, " => ", pv.treeRepr
    let pdfield = nnkPostfix.newTree(ident("*"), ident(pd)) 
    rec.add newIdentDefs(pdfield, pv)
  tp[0][^1][0][^1] = rec
  result.add tp
  echo "TYPE: \n", result.repr

var widgetArgsTable* {.compileTime.} = initTable[string, seq[(string, string, NimNode, )]]()

macro Widget*(widget, body: untyped): untyped =
  # echo "WITH: ", widget.repr
  # echo "WITH: ", body.repr
  let procName = widget.strVal

  result = newStmtList()
  var attrs = initTable[string, NimNode]()
  for idx, name, code in body.attributes():
    attrs[name] = code
  var args = newSeq[NimNode]()
  let widgetArgs = widgetArgsTable[procName]
  # echo "WITH: widgetArgs: ", widgetArgs.repr
  
  result = newStmtList()
  for (argname, propname, argtype) in widgetArgs:
    # echo "ARGNAME: ", argname
    # echo "PROPNAME: ", propname
    if argtype.repr == "WidgetProc" and attrs.hasKey(propname):
      let pargname = genSym(nskLet, argname & "Arg")
      let code =
        if attrs.hasKey(propname): attrs[propname]
        else: nnkDiscardStmt.newTree(newEmptyNode())
      let pdecl = makeLambdaDecl(pargname, argtype, code)
      # echo "PROCDECL: ", pdecl.repr
      result.add pdecl
      args.add newNimNode(nnkExprEqExpr).
        add(ident(argname)).add(pargname)
    elif argtype.repr == "WidgetProc":
      args.add newNimNode(nnkExprEqExpr).
        add(ident(argname)).add(newNilLit())
    else:
      let code =
        if attrs.hasKey(propname): attrs[propname]
        else: newNilLit()
      # echo "CODE: ", code.repr
      args.add newNimNode(nnkExprEqExpr).
        add(ident(argname)).add(code)
  result.add newCall(`procName`, args)

proc makeWidgetPropertyMacro(procName, typeName: string): NimNode =
  let
    labelMacroName = ident typeName
    wargsTable = ident "widgetArgsTable"

  var labelMacroDef = quote do:
    template `labelMacroName`*(body: untyped) =
      Widget `procName`, body

  result = newStmtList()
  result.add labelMacroDef
  echo "\n=== Widget: makeWidgetPropertyMacro === "
  echo result.repr

proc eventsMacro*(tp: string, blk: NimNode): NimNode =
  result = newStmtList()
  var tn = ident tp
  var code = blk
  var name = ident "evt"
  var matchBody = nnkCommand.newTree(ident "match", name, blk)
  echo "ON EVENTS: ", blk.treeRepr
  result.add quote do:
    var v {.inject.}: Variant
    if not current.hookEvents.data.isNil and
          current.hookEvents.data.pop(current.code, v):
      let `name` = v.get(`tn`)
      `matchBody`

proc makeStatefulWidget*(blk: NimNode, hasState: bool, defaultState: bool): NimNode =
  var
    procDef = blk
    body = procDef.body()
    params = procDef.params()
    pragmas = procDef.pragma()
    preBody = newStmtList()

  let
    hasEmptyReturnType = params[0].kind == nnkEmpty
    procName = procDef.name().strVal
    typeName =
      if hasEmptyReturnType: procName.capitalizeAscii()
      else: params[0].strVal
    groupName = newLit(procName)
    preName = ident("setup")
    postName = ident("post")

  if hasState and hasEmptyReturnType:
    warning("Fidgets with state should generally name their state typename using the return type. ", procDef)
  # echo "typeName: ", typeName
  # echo "widget: ", treeRepr blk
  var
    initImpl: NimNode = newStmtList()
    renderImpl: NimNode
    onEventsImpl: NimNode
    evtName: string
    hasProperty = false

  for idx, name, code in body.attributes():
    echo fmt"{idx=} {name=}"
    body[idx] = newStmtList()
    # echo "widget:property: ", name
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
      echo "FIDGETS:EVENTS:NAME: ", evtName 
      let code = code[1]
      echo "FIDGETS:EVENTS: ", evtName, " code: ", code.treeRepr
      preBody.add nnkCommand.newTree(ident "variant", evtIdent, code)
    of "onEvents":
      echo "FIDGETS:ONEVENTS: ", " code: ", code.treeRepr
      onEventsImpl = code

  echo "FIDGETS:eventsMacroName: ", evtName
  if not onEventsImpl.isNil:
    onEventsImpl = eventsMacro(evtName, onEventsImpl)
  else:
    onEventsImpl = newStmtList()

  if renderImpl.isNil:
    error("fidgets must provide a render body!", procDef)

  var typeNameSym = ident(typeName)

  let stateSetup =
    if not hasState:
      newStmtList()
    else:
      if defaultState:
        quote do:
          useState(`typeNameSym`)
      else:
        quote do:
          if self == nil:
            raise newException(ValueError, "app widget state can't be nil")

  procDef.body = newStmtList()
  procDef.body.add quote do:
    group `typeName`:
      `initImpl`
      `stateSetup`
      if `preName` != nil:
        `preName`()
      `onEventsImpl`
      `renderImpl`
      if `postName` != nil:
        `postName`()

  # handle return the Fidgets self state variables
  # echo "procTp:def: ", procDef.pragma.treeRepr
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
    stateArg =
      if defaultState: newIdentDefs(ident("self"), ident(typeName), newNilLit())
      else:            newIdentDefs(ident("self"), ident(typeName))
    preArg = newIdentDefs(preName, bindSym"WidgetProc", nilValue)
    postArg = newIdentDefs(ident("post"), bindSym"WidgetProc", nilValue)
  
  if hasState and hasProperty:
    params.add stateArg
  params.add preArg
  params.add postArg 
  # echo "procTp:return type match: ", hasStateReturnType
  # echo "procTp:params: ", params.treeRepr
  # echo "params: ", treeRepr params

  var widgetArgs = newSeq[(string, string, NimNode)]()
  for idx, argname, propname, argtype in params.propertyNames():
    let pname = if propname == "": argname else: propname
    widgetArgs.add( (argname, pname, argtype,) )

  widgetArgsTable[procName] = widgetArgs

  result = newStmtList()
  result.add preBody 
  result.add procDef
  if not hasState:
    result.add makeWidgetPropertyMacro(procName, typeName) 
  echo "\n=== StatefulWidget === "
  echo result.repr

macro basicFidget*(blk: untyped) =
  result = makeStatefulWidget(blk, hasState=false, defaultState=false)

template useState*[T](tp: typedesc[T]) =
  if current.hookStates.isEmpty():
    var self = tp()
    current.hookStates = newVariant(self)
  var self {.inject.} =
    if self.isNil:
      current.hookStates.get(tp)
    else:
      self

template useEvents*(): GeneralEvents =
  if current.hookEvents.data.isNil:
    current.hookEvents.data = newTable[string, Variant]()
  current.hookEvents

macro statefulFidget*(blk: untyped) =
  result = makeStatefulWidget(blk, hasState=true, defaultState=true)

macro appFidget*(blk: untyped) =
  result = makeStatefulWidget(blk, hasState=true, defaultState=false)

macro reverseStmts(body: untyped) =
  result = newStmtList()
  var stmts = newSeq[NimNode]()
  for ln in body:
    echo "reverseStmts: ", ln.repr
    stmts.insert(ln, 0)
  result.add stmts

template Horizontal*(child: untyped) =
  frame "autoFrame":
    layout lmHorizontal
    counterAxisSizingMode csAuto
    constraints cMin, cStretch
    itemSpacing 2.Em

    `child`

template Vertical*(child: untyped) =
  frame "autoFrame":
    layout lmVertical
    counterAxisSizingMode csAuto
    constraints cMin, cStretch
    itemSpacing 2.Em

    `child`

proc `||`*(x, y: int | float32 | float64): auto =
  if x == 0: y else: x
