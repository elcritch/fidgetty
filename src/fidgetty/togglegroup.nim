import button, widgets

fidgetty ToggleGroup[T: enum]:
  properties:
    defaultVal: T
  state:
    setSelected: bool
    selected: T

proc new*[T](_: typedesc[ToggleGroupProps[T]]): ToggleGroupProps[T] =
  new result

proc render*[T](
    props: ToggleGroupProps[T],
    self: ToggleGroupState[T]
): Events[ChangeEvent[T]] =

  if not self.setSelected:
    self.selected = props.defaultVal
    self.setSelected = true


  Horizontal:
    for x in T:
      Button:
        label $x
        size 10'em, 2'em
        isActive self.selected == x
        onClick:
          self.selected = x
          dispatchEvent changed(x)
