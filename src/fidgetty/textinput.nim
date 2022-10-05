import widgets
import times
import unicode
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
    editing: bool
    showCursor: bool
    ticks: Future[void] = emptyFuture()


proc handleClicked(self: TextInputState, textbox: TextBox[Node]) =
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
    # echo "selectWord"
    textbox.selectWord(mousePos)
    buttonDown[MOUSE_LEFT] = false
  # elif self.multiClick == 2:
  #   # echo "selectParagraph"
  #   self.textbox.selectParagraph(mousePos)
  #   buttonDown[MOUSE_LEFT] = false
  # elif self.multiClick == 3:
  #   self.textbox.selectAll()
  #   buttonDown[MOUSE_LEFT] = false
  else:
    textbox.mouseAction(mousePos, click = true, keyboard.shiftKey)

proc new*(_: typedesc[TextInputProps]): TextInputProps =
  new result
  cornerRadius theme.textCorner.UICoord
  shadows theme
  imageOf theme.gloss
  imageTransparency 0.33
  rotation 0
  fill palette.foreground

proc render*(
    props: TextInputProps,
    self: TextInputState,
): Events[All]=
  # Draw a progress bars
  text "text":
    useState[TextBox[Node]](textbox)

    # echo "mouseDown"
    let font = common.fonts[current.textStyle.fontFamily]
    # let evts = current.currentEvents()
    # self.textbox = evts.mgetOrPut("$textbox",

    if textbox.item.isNil:
      echo "textbox item isNil"
      textbox.item = current
      textbox.init(
          font,
          current.screenBox.w.scaled,
          current.screenBox.h.scaled,
          current,
          hAlignMode(current.textStyle.textAlignHorizontal),
          vAlignMode(current.textStyle.textAlignVertical),
          current.multiline,
          worldWrap = true,
          pattern = props.pattern
          )
      echo textbox.repr
    
    # setup focus
    fill palette.text
    current.bindingSet = true
    selectable true
    editableText true

    onClick:
      keyboard.focus(current, textbox)
      self.handleClicked(textbox)
      self.editing = true
      proc ticker(self: TextInputState) {.async.} =
        let cursorBlink = 1_000
        while self.editing:
          self.showCursor = not self.showCursor
          refresh()
          await sleepAsync(cursorBlink)
      
      if self.ticks.isNil or self.ticks.finished:
        # echo "ticker..."
        self.ticks = ticker(self)

    onClickOutside:
      keyboard.unFocus(current)
      self.editing = false
    
    let curr = $current.text

    if textbox.hasChange:
      if props.value != curr:
        dispatchEvent changed(curr)
    elif curr == "":
      textbox.text = props.value
    elif curr != props.value:
      if not (props.ignorePostfix and props.value.contains(curr)):
        textbox.text = props.value
    # clear change
    textbox.hasChange = false

    if font.size > 0:
      textbox.resize(current.box.scaled.wh)
      rectangle "cursor":
        let cursor = textbox.cursorRect()
        box cursor.descaled
        if self.showCursor and self.editing:
          fill blackColor
        else:
          fill clearColor
      for selection in textbox.selectionRegions():
        rectangle "selection":
          box selection.descaled
          fill palette.cursor * 0.22
  
