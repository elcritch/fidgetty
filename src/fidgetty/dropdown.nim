import widgets
import button

# mkWidget(DropdownMenu):
#   properties:
#     items: seq[string]
#     selected: int
#     defaultLabel: string
#     disabled: bool

#   events(AnimatedEvents):
#     IncrementBar(increment: float)
#     JumpToValue(target: float)
#     CancelJump

type
  DropdownArgs* = ref object
    items*: seq[string]
    selected*: int
    defaultLabel*: string
    disabled*: bool

  DropdownState* = ref object
    dropDownOpen: bool
    dropUp: bool
    itemsVisible: int
    itemsCount: int

static:
  assert DropdownArgs is WidgetArgs
  assert DropdownState is WidgetState

proc new*(_: typedesc[DropdownArgs]): DropdownArgs =
  new result
  size 8'em, 1.5'em
  fill clearColor
  imageColor clearColor

template DropdownMenu*(code: untyped): untyped =
  block:
    var item {.inject.}: DropdownArgs
    item.new()
    proc `items`(val: seq[string]) = item.items = val
    proc `defaultLabel`(val: string) = item.defaultLabel = val
    proc `selected`(val: int) = item.selected = val
    proc `disabled`(val: int) = item.selected = val
    `code`
    useState(DropdownState, state)
    render(item, state)

proc render*(
    args: DropdownArgs,
    self: DropdownState
) =
  ## dropdown widget 
  component "dropdown":
    let
      cb = current.box
      bw = cb.w
      bh = cb.h
      bih = bh * 1.0'ui
      tw = bw - 1.5'em

    proc resetState() = 
      self.dropDownOpen = false
      self.dropUp = false
      self.itemsVisible = -1

    if self.itemsCount != args.items.len():
      # echo "new dropdowns" 
      self.itemsCount = args.items.len()
      resetState()

    let
      visItems =
        if self.dropUp: 4
        elif self.dropDownOpen: self.itemsVisible
        else: args.items.len()
      itemCount = max(1, visItems).min(args.items.len())
      bdh = min(bih * itemCount.UICoord, windowLogicalSize.descaled.y/2'ui)

    if itemCount <= 2:
      self.dropUp = true
      self.itemsVisible = args.items.len()
      refresh()

    let this = current
    var outClick = false

    Button:
      disabled:
        args.disabled
      setup:
        box 0, 0, bw, bh
        clipContent true
        text "icon":
          box tw, 0, 1'em, bh
          fill palette.text
          if self.dropDownOpen: rotation -90
          else: rotation 0
          characters ">"
        onClickOutside:
          outClick = true
      label:
        if args.selected < 0:
          args.defaultLabel
        else:
          args.items[args.selected]
      onClick:
        self.dropDownOpen = true
        self.itemsVisible = -1
      post:
        if self.dropDownOpen:
          highlight palette.highlight

    let spad = 1.0'f32
    if self.dropDownOpen:

      group "dropDownScroller":
        if self.dropUp:
          box 0, bh-bdh-bh, bw, bdh
        else:
          box 0, bh, bw, bdh

        clipContent true
        zlevel ZLevelRaised
        cornerRadius theme
        strokeLine this

        group "menuoutline":
          box 0, 0, bw, bdh
          cornerRadius theme
          stroke theme.outerStroke

        group "menu":
          box 0, 0, bw, bdh
          layout lmVertical
          counterAxisSizingMode csAuto
          itemSpacing theme.itemSpacing
          scrollBars true

          onClickOutside:
            # echo "outClick: ", outClick
            if outClick == true:
              resetState()

          var itemsVisible = -1 + (if self.dropUp: -1 else: 0)
          for idx, buttonName in pairs(args.items):
            group "menuBtn":
              if current.screenBox.overlaps(scrollBox):
                itemsVisible.inc()
              box 0, 0, bw, bih
              layoutAlign laCenter

              let clicked = Button:
                label: buttonName
                setup:
                  clearShadows()
                  let ic = this.image.color
                  imageColor Color(r: 0, g: 0, b: 0, a: 0.20 * ic.a)
                  boxOf parent
                  cornerRadius 0
                  stroke theme.innerStroke
              if clicked:
                resetState()
                # echo fmt"dropdwon: set {selected=}"
                args.selected = idx


          # group "menuBtnBlankSpacer":
            # box 0, 0, bw, this.cornerRadius[0]
          
          if self.itemsVisible >= 0:
            self.itemsVisible = min(itemsVisible, self.itemsVisible)
          else:
            self.itemsVisible = itemsVisible
