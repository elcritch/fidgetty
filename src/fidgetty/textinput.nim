import widgets
import times
import strutils
import asyncdispatch # This is what provides us with async and the dispatcher
import re

# import typography/font
import fidget_dev/patches/textboxes


fidgetty TextInput:
  properties:
    value: string
    isActive: bool
    disabled: bool
    ignorePostfix: bool
    pattern: Regex = nil
  state:
    multiClick: int
    lastClickTime: float
    textBox: TextBox
    editing: bool
    showCursor: bool
    textBox: TextBox[Node]
    ticks: Future[void] = emptyFuture()


proc handleClicked(self: TextInputState) =
  # let mousePos = mouse.pos(raw=true) - current.screenBox.xy + current.totalOffset
  # let mousePos = mouse.pos(raw=true) + current.totalOffset
  let mousePos = mouse.pos

  # mouse actions click, drag, double clicking
  if epochTime() - self.lastClickTime < 0.5:
    inc self.multiClick
  else:
    self.multiClick = 0
  self.lastClickTime = epochTime()
  if self.multiClick == 1:
    echo "selectWord"
    self.textBox.selectWord(mousePos)
    buttonDown[MOUSE_LEFT] = false
  elif self.multiClick == 2:
    echo "selectParagraph"
    self.textBox.selectParagraph(mousePos)
    buttonDown[MOUSE_LEFT] = false
  elif self.multiClick == 3:
    self.textBox.selectAll()
    buttonDown[MOUSE_LEFT] = false
  else:
    self.textBox.mouseAction(mousePos, click = true, keyboard.shiftKey)

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

proc new*(_: typedesc[TextInputProps]): TextInputProps =
  new result
  # boxSizeOf parent
  cornerRadius theme.textCorner.UICoord
  shadows theme
  imageOf theme.gloss
  imageTransparency 0.33
  rotation 0
  fill palette.foreground

proc render*(
    props: TextInputProps,
    self: TextInputState,
): Events =
  # Draw a progress bars

  stroke theme.outerStroke
  fill palette.textBg
  clipContent true

  if props.disabled:
    imageColor palette.disabled
  else:
    if self.editing:
      rotation 180
      stroke palette.highlight * 0.40
      strokeWeight 0.2'em
    if props.isActive:
      highlight palette

  text "text":
    fill palette.text

    # setup focus
    current.bindingSet = true
    selectable true
    editableText true

    onClick:
      keyboard.focus(current, self.textBox)
      self.handleClicked()
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
        current,
        hAlignMode(current.textStyle.textAlignHorizontal),
        vAlignMode(current.textStyle.textAlignVertical),
        current.multiline,
        worldWrap = true,
        pattern = props.pattern
        ))
    
    let curr = $current.text

    if self.textBox.hasChange:
      if props.value != curr:
        dispatchEvent Strings(curr)
    elif curr == "":
      self.textBox.text = props.value
    elif curr != props.value:
      if not (props.ignorePostfix and props.value.contains(curr)):
        self.textBox.text = props.value
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
