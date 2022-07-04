import widgets
import times

# import typography/font
import fidget/patches/textboxes

var
  # Used for double-clicking
  multiClick: int
  lastClickTime: float
  currLevel: ZLevel

proc handleClicked(textBox: TextBox) =
  # let mousePos = mouse.pos(raw=true) - current.screenBox.xy + current.totalOffset
  # let mousePos = mouse.pos(raw=true) + current.totalOffset
  let mousePos = mouse.pos

  # mouse actions click, drag, double clicking
  if epochTime() - lastClickTime < 0.5:
    inc multiClick
  else:
    multiClick = 0
  lastClickTime = epochTime()
  if multiClick == 1:
    echo "selectWord"
    textBox.selectWord(mousePos)
    buttonDown[MOUSE_LEFT] = false
  elif multiClick == 2:
    echo "selectParagraph"
    textBox.selectParagraph(mousePos)
    buttonDown[MOUSE_LEFT] = false
  elif multiClick == 3:
    textBox.selectAll()
    buttonDown[MOUSE_LEFT] = false
  else:
    echo "mouseAction"
    textBox.mouseAction(mousePos, click = true, keyboard.shiftKey)

proc handleDrag(textBox: TextBox) =
  let mousePos = mouse.pos(raw=true) + current.totalOffset
  if textBox != nil and
      mouse.down and
      not mouse.click and
      keyboard.focusNode == current:
    # Dragging the mouse:
    echo "dragging mouse"
    textBox.mouseAction(mousePos, click = false, keyboard.shiftKey)

import print

proc textInput*(
    value {.property: value.}: string,
    isActive {.property: isActive.}: bool = false,
    disabled {.property: disabled.}: bool = false
): TextInputState {.statefulFidget, discardable.} =
  # Draw a progress bars
  init:
    box 0, 0, 8.Em, 2.Em
    cornerRadius theme.textCorner
    shadows theme
    imageOf theme.gloss
    imageTransparency 0.33
    rotation 0
    fill palette.foreground

  properties:
    editing: bool
    changed: bool
    textBox: TextBox[Node]

  render:
    # echo "text bind internal: ", current.screenBox
    stroke theme.outerStroke
    text "text":
      fill palette.text
      let font = common.fonts[current.textStyle.fontFamily]
      # echo "mouseDown"
      let evts = current.currentEvents()
      self.textBox = evts.mgetOrPut("$textbox",
        newTextBox[Node](
          font,
          current.screenBox.w.scaled,
          current.screenBox.h.scaled,
          font.size * adjustTopTextFactor,
          current,
          hAlignMode(current.textStyle.textAlignHorizontal),
          vAlignMode(current.textStyle.textAlignVertical),
          current.multiline,
          worldWrap = true))
      if font.size > 0:
        let cursor = self.textBox.cursorRect()
        rectangle "cursor":
          # box cursor.descaled
          let cb = cursor.descaled
          box cb.x + 50'pw, cb.y + 50'ph + 0.25'em, cb.w, cb.h
          fill palette.cursor
      # setup focus
      current.bindingSet = true
      selectable true
      editableText true
      onClick:
        keyboard.focus(current, self.textBox)
        handleClicked(self.textBox)
      onClickOutside:
        keyboard.unFocus(current)
      onInput:
        let input = $keyboard.input
        if value != input:
          self.changed = true

    fill palette.textBg
    clipContent true
    if disabled:
      imageColor palette.disabled
    else:
      onHover:
        # imageTransparency 0.0
        rotation 180
        stroke palette.highlight * 0.40
        strokeWeight 0.2'em
      if isActive:
        highlight palette

proc textInputBind*(
    value {.property: value.}: var string,
    isActive {.property: isActive.}: bool = false,
    disabled {.property: disabled.}: bool = false,
): bool {.wrapperFidget, discardable.} =
  # Draw a progress bars
  let curr = value
  let res = textInput(curr, isActive, disabled, nil, setup, post, id)
  if res.changed:
    value = $res.textBox.runes

