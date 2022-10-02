import widgets
import behaviors/dragger

export dragger

variants TabEvent:
  ## variant case types for scroll events
  ScrollTo(perc: float32)
  ScrollPage(amount: float32)

fidgetty TabView:
  properties:
    triggers: Events[All]
  state:
    activeTab: int

template tab*(name, blk: untyped) =
  ## sets up split panes. options are "menu", "main", and "bar".
  ## 
  ## "bar" sets up the middle bar, use `draggable` property
  ## to be able to be dragged.
  ## 
  rectangle "split-menu":
    gridRow "area"
    gridColumn "menu"
    `blk`


proc new*(_: typedesc[TabViewProps]): TabViewProps =
  new result
  result.sliderFraction = 0.33

proc new*(_: typedesc[TabViewState]): TabViewState =
  new result
  box 0, 0, 100'pp, 2.Em
  textAutoResize tsHeight
  layoutAlign laStretch
  stroke theme.outerStroke

import print

proc render*(
    props: TabViewProps,
    self: TabViewState,
): Events[All]=
  ## Renders a TabView which is a vertical bar splitting
  ## an area into two with a draggable bar in between.
  
  # Setup CSS Grid Template
  box 0, 0, 100'pp, 100'pp
  gridTemplateRows ["area"] 1'fr
  
  gridTemplateColumns ["menu"] csPerc(100.0 * props.sliderFraction) \
                      ["bar"] csFixed(0.5'em) \
                      ["main"] 2'fr
  