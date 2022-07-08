import std/strformat, std/hashes, std/sequtils
import parseutils, memo
import re

import fidgetty
import fidgetty/textinput
import fidgetty/themes

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

type
  Fahrenheit = distinct float
  Celsius = distinct float

func toF*(val: Celsius): Fahrenheit =
  Fahrenheit val.float * (9.0/5.0) + 32.0
func toF*(val: Fahrenheit): Fahrenheit =
  val

func toC*(val: Fahrenheit): Celsius =
  Celsius (val.float - 32.0) * (5.0/9.0)
func toC*(val: Celsius): Celsius =
  val

template parseTemp(val, kind: untyped) =
  if `val`.updated.isSome():
    var res: float
    if parseFloat(`val`.updated.get().strip(), res, 0) > 0:
      self.temp = `kind`(res).toC()

proc exampleApp*(): ExampleApp {.appFidget.} =
  ## defines a stateful app widget
  properties:
    temp: Celsius

  render:
    setTitle(fmt"Fidget Animated Progress Example")
    textStyle theme
    fill palette.background
    box 0, 0, 100'vw, 100'vh
    Vertical:
      box 1'em, 1'em, 100'vw, 100'vh
      Spacer 0, 50'ph - 2'em
      Horizontal:
        HSpacer 1'em
        let cVal =
          TextInput:
            value: fmt"{toC(self.temp).float:5.1f}".strip()
            setup: size 5'em, 2'em
            ignorePostfix: true
            pattern: re"[0-9\.]"
        text "data":
          size 6'em, 2'em
          fill palette.text
          characters: fmt"Celsius"
        text "data":
          size 3'em, 2'em
          fill palette.text
          characters: fmt" = "
        let fVal =
          TextInput:
            value: fmt"{toF(self.temp).float:5.1f}".strip()
            setup: size 5'em, 2'em
            ignorePostfix: true
            pattern: re"[0-9\.]"
        text "data":
          size 6'em, 2'em
          fill palette.text
          characters: fmt" Fahrenheit"

        cVal.parseTemp(Celsius)
        fVal.parseTemp(Fahrenheit)


startFidget(
  wrapApp(exampleApp, ExampleApp),
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w = 440,
  h = 140,
  uiScale = 2.0)
