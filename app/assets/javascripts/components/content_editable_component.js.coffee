# modified from: https://github.com/KasperTidemann/ember-contenteditable-view

ETahi.ContentEditableComponent = Em.Component.extend
  attributeBindings: ['contenteditable', 'placeholder']

  editable: true
  placeholder: ""
  plaintext: false
  preventEnterKey: false
  caretPosition: null

  _userIsTyping: false

  setup: (->
    @setHTMLFromValue()
    @setPlaceholder() if @elementIsEmpty() and @get('placeholder')
  ).on('didInsertElement')

  # Properties:
  contenteditable: (->
    (if @get('editable') then 'true' else `undefined`)
  ).property('editable')

  # Observers:
  valueDidChange: (->
    @setHTMLFromValue() if @get('value') and not @get('_userIsTyping')
  ).observes('value')

  # DOM Events:
  keyDown: (event) ->
    @set('_userIsTyping', true)
    @supressEnterKeyEvent(event) if @get('preventEnterKey')
    @removePlaceholder() if @elementHasPlaceholder()

  keyUp: (event) ->
    @saveCaretPosition()

    if @elementIsEmpty() || @elementHasPlaceholder()
      @set('value', '')
      @setPlaceholder()
      return

    @setValueFromHTML()

  focusIn: ->
    @saveCaretPosition()

  focusOut: ->
    @set '_userIsTyping', false
    @setPlaceholder() if @elementIsEmpty()

  saveCaretPosition: ->
    if(window.getSelection)
      return if window.getSelection().rangeCount == 0
      @set('caretPosition', window.getSelection().getRangeAt(0).startOffset)
    else if(document.selection)
      @set('caretPosition', document.selection.createRange().startOffset)

  restoreCaretPosition: ->
    range = document.createRange()

    range.setStart @$()[0].childNodes[0], @get('caretPosition')
    window.getSelection().removeAllRanges()
    window.getSelection().addRange(range)

  elementIsEmpty: ->
    Em.isEmpty(@.$().text())

  elementHasPlaceholder: ->
    @.$().text() == @get('placeholder')

  setPlaceholder: ->
    @.$().text(@get('placeholder'))
    @mute()

  removePlaceholder: ->
    @.$().text('')
    @unmute()

  setHTMLFromValue: ->
    if @get('caretPosition')
      offset = @get('caretPosition')
      @restoreCaretPosition()
    else
      @$().html(@get('value'))

    @unmute()

  mute: ->
    @.$().addClass('content-editable-muted')

  unmute: ->
    @.$().removeClass('content-editable-muted')

  setValueFromHTML: ->
    if @get('plaintext')
      @set 'value', @.$().text()
    else
      @set 'value', @.$().html()

  supressEnterKeyEvent: (e) ->
    if e.keyCode == 13 || e.which == 13
      e.preventDefault()
