import theming
import fidget_dev/commonutils
export commonutils, theming

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
    counterAxisSizingMode CounterAxisSizingMode.csAuto
    `child`

template Horizontal*(child: untyped) =
  Horizontal("horizontal", child)

template Vertical*(text, child: untyped) =
  group text:
    layout lmVertical
    counterAxisSizingMode CounterAxisSizingMode.csAuto
    `child`

template Vertical*(child: untyped) =
  Vertical("vertical", child)

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