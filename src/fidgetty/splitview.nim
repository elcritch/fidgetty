import fidget_dev
import widgets

fidgetty SplitView:
  properties:
    value: float
    label: string
  state:
    pipDrag: bool
    pipPos: Position
    barOffset: float
    barVal: float

template SplitBar*(blk: untyped) =
  block:
    useState[SplitViewState](state)

    rectangle "bar":
      gridRow "main"
      gridColumn "bar"

      `blk`

      onClick:
        state.pipDrag = true
        state.pipPos = current.mouseRelativeStart()
        state.barVal = self.barVal + self.barOffset

      if state.pipDrag:
        state.pipDrag = buttonDown[MOUSE_LEFT]
        state.barOffset = state.pipPos.mouseRelativeDiff().x.float32

proc new*(_: typedesc[SplitViewProps]): SplitViewProps =
  new result
  box 0, 0, 100'pp, 2.Em
  textAutoResize tsHeight
  layoutAlign laStretch
  stroke theme.outerStroke

proc render*(
    props: SplitViewProps,
    self: SplitViewState,
): Events =
  ## Renders a SplitView which is a vertical bar splitting
  ## an area into two with a draggable bar in between.
  
  # Setup CSS Grid Template
  box 0, 0, 100'vw, 100'vh
  gridTemplateRows ["top"] csFixed(Em(1)) \
                    ["main"] 1'fr \
                    ["bottom"] csFixed(Em(1))
  
  gridTemplateColumns ["left"] csFixed(Em(1)) \
                    ["menu"] csFixed(10'em.float32 + self.barVal + self.barOffset) \
                    ["bar"] csFixed(0.5'em) \
                    ["area"] 2'fr \
                    ["right"] csFixed(Em(1))

  rectangle "border":
    cornerRadius 0.2'em
    gridRow "main"
    gridColumn "menu" // "right"
    stroke 0.1'em.float32, blackColor
  
  # echo "splitter:self: ", repr self
  echo "splitview:self: ", self.unsafeAddr.pointer.repr

