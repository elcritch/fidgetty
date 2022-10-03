import std/strformat, std/hashes, std/sequtils
import parseutils
import re

import fidgetty
import fidgetty/themes
import fidgetty/textinput
import fidgetty/text

loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")

## Some basics for handling temp conversions between
## Celsius and Fahrenheit. 
## 
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

type
  ExampleApp = ref object
    temp: Celsius

proc labeledTextInput[T](
    self: ExampleApp,
) =
  ## setup a textinput and then when it's
  ## updated parse the string and set the
  ## new value
  let sval =
    when T is Fahrenheit: toF(self.temp).float
    else: self.temp.float
  
  TextInput:
    value fmt"{sval:5.1f}".strip()
    size 5'em, 2'em
    pattern re"[0-9\.]"
    ignorePostfix true
  do -> ChangeEvent[string]:
    Changed(val):
      var res: float
      if parseFloat(val.strip(), res, 0) > 0:
        self.temp = T(res).toC()
        refresh()

proc exampleApp*() =
  ## defines a stateful app widget
  useState[ExampleApp](self)

  setTitle(fmt"Fidget Animated Progress Example")
  textStyle theme
  fill palette.background
  box 0, 0, 100'vw, 100'vh
  setWindowBounds(vec2(400, 200), vec2(600, 400))

  rectangle:
    box 0, 0, 400, 200
    fill "#DEDEDE"
    cornerRadius 0.5'em

    Centered:
      Horizontal:
        # deg C
        TextBox:
          label "Celsius: "
        labeledTextInput[Celsius](self)
        TextBox:
          label " = "
        # deg F
        TextBox:
          label "Fahrenheit: "
        
        labeledTextInput[Fahrenheit](self)


startFidget(
  exampleApp,
  setup = 
    when defined(demoBulmaTheme): setup(bulmaTheme)
    else: setup(grayTheme),
  w = 400,
  h = 200)
