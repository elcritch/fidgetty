import std/strformat, std/hashes, std/sequtils
import parseutils, memo
import re

import fidgetty
import fidgetty/themes
import fidgetty/textinput
import fidgetty/fields

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

# template parseTemp(val, kind: untyped) =
#   if `val`.updated.isSome():
#     var res: float
#     if parseFloat(`val`.updated.get().strip(), res, 0) > 0:
#       self.temp = `kind`(res).toC()

type
  ExampleApp = ref object
    temp: Celsius

import print

proc labeledTextInput[T](
    self: ExampleApp,
) =
  let sval =
    when T is Fahrenheit: toF(self.temp).float
    else: self.temp.float
  
  TextInput:
    value fmt"{sval:5.1f}".strip()
    size 5'em, 2'em
    pattern re"[0-9\.]"
    ignorePostfix true
  finally:
    processEvents(ValueChange):
      Strings(val):
        var res: float
        if parseFloat(val.strip(), res, 0) > 0:
          print "update: ", T(res)
          self.temp = T(res).toC()
          refresh()

proc exampleApp*() =
  ## defines a stateful app widget
  useState(ExampleApp, self)

  setTitle(fmt"Fidget Animated Progress Example")
  textStyle theme
  fill palette.background
  box 0, 0, 100'vw, 100'vh
  setWindowBounds(vec2(400, 200), vec2(600, 400))

  Centered:
    rectangle:
      box 0, 0, 400, 200
      fill "#DEDEDE"
      cornerRadius 0.5'em

      Centered:
        Horizontal:
          # deg C
          text:
            fill palette.text
            let lbl1 = "Celsius: "
            characters lbl1
            size lbl1.len().float.Em/2.0, 2'em
          labeledTextInput[Celsius](self)
          # cVal.parseTemp(Celsius)
          text:
            fill palette.text
            characters " = "
            size 3'em, 2'em

          # deg F
          text:
            fill palette.text
            let lbl2 = "Fahrenheit: "
            characters lbl2
            size lbl2.len().float.Em/2.0, 2'em
          labeledTextInput[Fahrenheit](self)
          # fVal.parseTemp(Fahrenheit)


startFidget(
  exampleApp,
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w = 400,
  h = 200,
  uiScale = 2.0)
