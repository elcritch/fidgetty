import bumpy, fidget
import fidgets

export fidget, fidgets

proc gradbutton*(
    message {.property: text.}: string,
    clicker {.property: onClick.}: WidgetProc = proc () = discard
): bool {.basicFidget, discardable.} =
  # Draw a progress bars 
  init:
    box 0, 0, 8.Em, 2.Em

  let
    bw = current.box().w
    bh = current.box().h

  cornerRadius 3
  image "shadow-button.png"
  fill "#BDBDBD", 1
  strokeLine 2, "#707070", 1.0
  current.imageColor = color(1,1,1,1.0)
  clipContent true

  rectangle "button":
    box 0, 0, bw, bh
    dropShadow 3, 0, 0, "#000000", 0.03
    cornerRadius 3
    fill "#BDBDBD", 0.5
    strokeLine 2, "#707070", 1.0

    onHover:
      fill "#BEEBFD", 0.7
    onClick:
      clicker()
      result = true

    text "text":
      box 0, 0, bw, bh
      fill "#565555"
      characters message

proc drawMain() =
  frame "main":
    font "IBM Plex Sans", 16, 200, 0, hCenter, vCenter
    # we call exampleApp with a pre-made state
    # the `statefulWidget` always takes a `self` paramter
    # that that widgets state reference 
    Vertical:
      verticalPadding 3'em
      horizontalPadding 3'em
      gradbutton("test button 1"):
        echo "click 1"
      gradbutton("test button 2"):
        echo "click 2"

when isMainModule:
  loadFont("IBM Plex Sans", "IBMPlexSans-Regular.ttf")
  startFidget(drawMain, uiScale=2.0)