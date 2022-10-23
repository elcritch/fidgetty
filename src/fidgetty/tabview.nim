import widgets
import behaviors/dragger
import themes
import button

export dragger

fidgetty TabView:
  properties:
    selected: string
  state:
    currentTab: Hash
    changed: bool
    tabs: OrderedSet[string]

template tab*(name, blk: untyped) =
  ## sets up split panes. options are "menu", "main", and "bar".
  ## 
  ## "bar" sets up the middle bar, use `draggable` property
  ## to be able to be dragged.
  ## 
  state.tabs.incl name
  if state.currentTab == name.hash():
    rectangle name:
      # current.disableRender = state.currentTab != name.hash()
      gridRow "main" // "end"
      gridColumn "area"
      themeExtra atom"area"
      `blk`

proc new*(_: typedesc[TabViewProps]): TabViewProps =
  new result

proc new*(_: typedesc[TabViewState]): TabViewState =
  new result
  box 0, 0, 100'pp, 2.Em
  textAutoResize tsHeight
  layoutAlign laStretch
  stroke theme.outerStroke

import print

proc preRender*(
    props: TabViewProps,
    self: TabViewState,
) =
  if self.changed:
    common.resetNodes.inc
  # Setup CSS Grid Template
  box 0, 0, 100'pp, 100'pp
  gridTemplateRows ["menu"] csFixed(2'em) \
                   ["bar"] csFixed(0.5'em) \
                   ["main"] 2'fr \
                   ["end"]
  gridTemplateColumns ["area"] 1'fr ["end"]

proc render*(
    props: TabViewProps,
    self: TabViewState,
): Events[All]=
  ## Renders a TabView which is a vertical bar splitting
  ## an area into two with a draggable bar in between.
  
  if self.changed:
    common.resetNodes.dec
    self.changed = false
  
  # rectangle "bar":
  #   gridRow "bar"
  #   gridColumn "area"
  #   stroke theme.outerStroke
  #   imageOf theme.gloss
  #   fill palette.foreground
      
  rectangle "menu":
    gridRow "menu"
    gridColumn "area"

    Horizontal:
      for tab in self.tabs:
        let th = tab.hash()
        Button:
          # clearShadows()
          imageTransparency 0.1
          boxOf parent
          cornerRadius 0
          stroke theme.innerStroke

          size 6'em, 2'em
          label tab
          isActive self.currentTab == th
          onClick:
            self.currentTab = th
            self.changed = true
            dispatchEvent changed(tab)
            refresh()
  