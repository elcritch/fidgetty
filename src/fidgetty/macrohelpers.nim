
import macros, tables, strutils, strformat, math, random, options
import bumpy, variant, patty
import std/macrocache

import macroutils

type
  WidgetArgs* = (string, string, NimNode)

  Property* = object
    name*: string
    label*: string
    argtype*: NimNode

  Attribute* = object
    name*: string
    code*: NimNode

proc makeWidgetArg*(arg: WidgetArgs): NimNode =
  # widgetArgs.add( (argname, pname, argtype,) )
  result = superQuote do:
    (`arg[0]`, `arg[1]`, `arg[2]`)

proc makeWidgetArgs*(args: seq[WidgetArgs]): NimNode =
  result = nnkBracketExpr.newTree()
  for arg in args:
    result.add arg.makeWidgetArg()

proc toWidgetArg*(arg: NimNode): WidgetArgs =
  arg.expectKind(nnkTupleConstr)
  result = (arg[0].strVal, arg[1].strVal, arg[2])

proc toWidgetArgs*(args: NimNode): seq[WidgetArgs] =
  args.expectKind(nnkBracketExpr)
  for an in args:
    result.add an.toWidgetArg()

proc makeLambdaDecl*(
    pargname: NimNode,
    argtype: NimNode,
    code: NimNode,
): NimNode =
  result = LetSection(
    nnkIdentDefs.newTree(
      pargname,
      argtype,
      nnkLambda.newTree(
        Empty(),
        Empty(),
        Empty(),
        FormalParams(Empty()),
        Empty(),
        Empty(),
        code,
      )
    )
  )

iterator attributes*(blk: NimNode): (int, Attribute) =
  for idx, item in blk:
    if item.kind == nnkCall:
      var name = item[0].repr
      if item.len() > 2:
        let code = newStmtList(item[1..^1])
        yield (idx, Attribute(name: name, code: code))
      else:
        yield (idx, Attribute(name: name, code: item[1]))

iterator propertyNames*(params: NimNode): (int, Property) =
  for idx, item in params:
    if item.kind == nnkEmpty:
      continue
    elif item.kind == nnkIdentDefs and item[0].kind == nnkPragmaExpr:
      var name = item[0][0].repr
      var pname = item[0][1][0][1].strVal
      var code = item[1]
      yield (idx, Property(name: name, label: pname, argtype: code))
    elif item.kind == nnkIdentDefs and item[0].kind == nnkIdent:
      var name = item[0].repr
      var code = item[1]
      yield (idx, Property(name: name, label: "", argtype: code))

proc makeType*(name: string, body: NimNode): NimNode =
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

proc makeSetters*(name: string, body: NimNode): NimNode =
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
  for pd, pv in propTypes:
    echo "PD: ", pd
    echo "PV: ", treeRepr pv
