`import Ember from 'ember'`
# modified from: https://github.com/KasperTidemann/ember-contenteditable-view

ContentEditableComponent = Ember.Component.extend
  attributeBindings: ['contenteditable', 'placeholder']

  editable: true
  placeholder: ""
  plaintext: false
  preventEnterKey: false

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
    if @elementIsEmpty() || @elementHasPlaceholder()
      @set('value', '')
      @setPlaceholder()
      return

    @setValueFromHTML()

  focusOut: ->
    @set '_userIsTyping', false
    @setPlaceholder() if @elementIsEmpty()

  elementIsEmpty: ->
    Ember.isEmpty(@.$().text())

  elementHasPlaceholder: ->
    @.$().text() == @get('placeholder')

  setPlaceholder: ->
    @.$().text(@get('placeholder'))
    @mute()

  removePlaceholder: ->
    @.$().text('')
    @unmute()

  setHTMLFromValue: ->
    @.$().html(@get('value'))
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

`export default ContentEditableComponent`
