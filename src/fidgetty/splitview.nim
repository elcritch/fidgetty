import widgets
import behaviors/dragger

fidgetty SplitView:
  properties:
    sliderFraction: float
  state:
    dragger: Dragger

template SplitBar*(blk: untyped) =
  ## item
  rectangle "bar":
    gridRow "main"
    gridColumn "bar"

    template draggable(enable: bool): untyped =
      ## enable slider dragging
      if enable:
        behavior state.dragger

        let sliderPos = state.dragger.position(
          self.pos,
          0'ui,
          node = parent,
          normalized=true
        )
        # print sliderPos
        if sliderPos.updated:
          sliderFraction state.dragger.value
          refresh()
    
    `blk`


proc new*(_: typedesc[SplitViewProps]): SplitViewProps =
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
  gridTemplateRows ["main"] 1'fr
  
  gridTemplateColumns ["menu"] csPerc(100.0 * props.sliderFraction) \
                    ["bar"] csFixed(0.5'em) \
                    ["area"] 2'fr

  # rectangle "border":
  #   cornerRadius 0.2'em
  #   gridRow "main"
  #   gridColumn "menu" // "area"
  #   stroke 0.1'em.float32, blackColor
