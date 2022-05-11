import std/strformat, std/hashes, std/sequtils

import fidgetty
import fidgetty/[button, textinput]

import parseutils
import memo

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

type
  Fahrenheit = distinct float
  Celsius = distinct float

func toF*(val: Celsius): Fahrenheit = Fahrenheit val.float * (9.0/5.0) + 32.0
func toF*(val: Fahrenheit): Fahrenheit = val

func toC*(val: Fahrenheit): Celsius = Celsius (val.float - 32.0) * (5.0/9.0)
func toC*(val: Celsius): Celsius = val

template parseTemp(val, kind: untyped) =
  if `val`.isSome:
    var res: float
    if parseFloat(`val`.get().strip(), res, 0) > 0:
      self.temp = `kind`(res).toC()

proc exampleApp*(): ExampleApp {.appFidget.} =
  ## defines a stateful app widget
  properties:
    temp: Celsius

  render:
    let currEvents = useEvents()
    setTitle(fmt"Fidget Animated Progress Example")
    textStyle theme
    fill theme
    box 0, 0, 100'vw, 100'vh

    frame "test":
      box 1'em, 1'em, 100'vw, 100'vh
      Horizontal:
        box 1'em, 1'em, 100'vw, 100'vh
        autoOrg
        counterAxisSizingMode csAuto
        constraints cMin, cStretch
        blank: size(0, 0)

        let cValStr = TextInput:
          value: fmt"{toC(self.temp).float:5.1f}".strip()
          setup:
            size 5'em, 2'em
            constraints cScale, cMin

        text "data":
          size 4'em, 2'em
          fill theme.textFill
          characters: fmt"Celsius"
          constraints cScale, cMin

        text "data":
          size 3'em, 2'em
          fill theme.textFill
          characters: fmt" = "
          constraints cScale, cScale

        let fValStr = TextInput:
          value: fmt"{toF(self.temp).float:5.1f}".strip()
          setup:
            size 5'em, 2'em
            constraints cScale, cMin

        text "data":
          size 6'em, 2'em
          fill theme.textFill
          characters: fmt" Fahrenheit"
        cValStr.parseTemp(Celsius)
        fValStr.parseTemp(Fahrenheit)


startFidget(wrapApp(exampleApp, ExampleApp),
            theme = grayTheme, w = 600, h = 100, uiScale = 2.0)
