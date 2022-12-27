import fidget_dev/common

export common

type
  ChangeKind* = enum
    NoChange
    Changed
    ChangeError
  
  ChangeEvent*[T] = ref object of Event
    case kind*: ChangeKind
    of Changed:
      value*: T
    of NoChange:
      prev*: T
    of ChangeError:
      old*: T
      curr*: T

proc changed*[T](value: T): ChangeEvent[T] =
  ChangeEvent[T](kind: Changed, value: value)

variants ValueChange:
  ## variant case types generic value changes
  Bool(bval: bool)
  Float(fval: float)
  Strings(sval: string)

template forEvents*(evts, body: untyped): untyped =
  var evts: seq[`tp`]
  {.push warning[UnreachableElse]: off.}
  for event {.inject.} in evts:
    `match`
  {.pop.}
