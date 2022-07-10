import widgets
import times
import strutils
import asyncdispatch # This is what provides us with async and the dispatcher
import re

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
    value : string,
    isActive : bool = false,
    disabled : bool = false,
    ignorePostfix : bool = false,
    pattern : Regex = nil,
): TextInputState {.statefulFidget, discardable.} =
  # Draw a progress bars
  init:
    # boxSizeOf parent
    cornerRadius theme.textCorner.UICoord
    shadows theme
    imageOf theme.gloss
    imageTransparency 0.33
    rotation 0
    fill palette.foreground

  properties:
    editing: bool
    updated: Option[string]
    showCursor: bool
    textBox: TextBox[Node]
    ticks: Future[void] = emptyFuture()

  render:
    # echo "text bind internal: ", current.screenBox
    stroke theme.outerStroke
    fill palette.textBg
    clipContent true

    if disabled:
      imageColor palette.disabled
    else:
      if self.editing:
        rotation 180
        stroke palette.highlight * 0.40
        strokeWeight 0.2'em
      if isActive:
        highlight palette

    text "text":
      fill palette.text

      # setup focus
      current.bindingSet = true
      selectable true
      editableText true

      onClick:
        keyboard.focus(current, self.textBox)
        handleClicked(self.textBox)
        self.editing = true
        proc ticker(self: TextInputState) {.async.} =
          let cursorBlink = 1_000
          while self.editing:
            self.showCursor = not self.showCursor
            refresh()
            await sleepAsync(cursorBlink)
        
        if self.ticks.isNil or self.ticks.finished:
          echo "ticker..."
          self.ticks = ticker(self)

      onClickOutside:
        keyboard.unFocus(current)
        self.editing = false
      
      # echo "mouseDown"
      let font = common.fonts[current.textStyle.fontFamily]
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
          worldWrap = true,
          pattern = pattern
          ))
      
      let curr = $current.text
      self.updated = none[string]()

      if self.textBox.hasChange:
        if value != curr:
          self.updated = some(curr)
      # elif inputRunes != self.textBox.text:
      elif curr == "":
        self.textBox.text = value
      elif curr != value:
        if not (ignorePostfix and value.contains(curr)):
          self.updated = none[string]()
          self.textBox.text = value
      # clear change
      self.textBox.hasChange = false

      if font.size > 0:
        self.textBox.resize(current.box.scaled.wh)
        rectangle "cursor":
          let cursor = self.textBox.cursorRect()
          box cursor.descaled
          if self.showCursor and self.editing:
            fill blackColor
          else:
            fill clearColor
        for selection in self.textBox.selectionRegions():
          rectangle "selection":
            box selection.descaled
            fill palette.cursor * 0.22


proc textInputBind*(
    value : var string,
    isActive : bool = false,
    disabled : bool = false,
    ignorePostfix : bool = false,
    pattern : Regex = nil,
): bool {.wrapperFidget, discardable.} =
  # Draw a progress bars
  let curr = value
  let res = textInput(curr, isActive, disabled, ignorePostfix, pattern, nil, setup, post, id)
  if res.updated.isSome():
    value = res.updated.get()

