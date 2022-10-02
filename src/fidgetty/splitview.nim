import widgets
import behaviors/dragger

export dragger

fidgetty SplitView:
  properties:
    sliderFraction: float
  state:
    dragger: Dragger

template split*(name, blk: untyped) =
  ## sets up split panes. options are "menu", "main", and "bar".
  ## 
  ## "bar" sets up the middle bar, use `draggable` property
  ## to be able to be dragged.
  ## 
  when name == "menu":
    rectangle "split-menu":
      gridRow "area"
      gridColumn "menu"
      `blk`
  elif name == "main":
    rectangle "split-area":
      gridRow "area"
      gridColumn "main"
      `blk`
  elif name == "bar":
    rectangle "bar":
      gridRow "area"
      gridColumn "bar"
      `blk`


proc new*(_: typedesc[SplitViewProps]): SplitViewProps =
  new result
  result.sliderFraction = 0.33

proc new*(_: typedesc[SplitViewState]): SplitViewState =
  new result
  box 0, 0, 100'pp, 2.Em
  textAutoResize tsHeight
  layoutAlign laStretch
  stroke theme.outerStroke

import print

proc render*(
    props: SplitViewProps,
    self: SplitViewState,
): Events =
  ## Renders a SplitView which is a vertical bar splitting
  ## an area into two with a draggable bar in between.
  
  # Setup CSS Grid Template
  box 0, 0, 100'pp, 100'pp
  gridTemplateRows ["area"] 1'fr
  
  gridTemplateColumns ["menu"] csPerc(100.0 * props.sliderFraction) \
                      ["bar"] csFixed(0.5'em) \
                      ["main"] 2'fr
  