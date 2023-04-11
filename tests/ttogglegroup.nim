
import fidgetty
import fidgetty/togglegroup

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

type
  MyEnum = enum
    a, b, c, d
  MySecondEnum = enum
    Hmm, This, Is, A, Test

proc exampleApp*() =
  frame "main":
    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
    group "ToggleGroup":
      Vertical:
        itemSpacing 1.5'em
        ToggleGroup[MyEnum]:
          size 10'em, 2'em
        do -> ChangeEvent[MyEnum]:
          Changed(val):
            echo "You clicked: ", val
            refresh()
        ToggleGroup[MySecondEnum]:
          discard
        do -> ChangeEvent[MySecondEnum]:
          Changed(val):
            echo "You clicked: ", val
            refresh()



startFidget(
  exampleApp,
  setup = 
    when defined(demoBulmaTheme): bulmaTheme
    else: grayTheme,
  w=680, h=400
)
