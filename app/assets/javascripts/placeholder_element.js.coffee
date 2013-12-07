window.Tahi ||= {}

class Tahi.PlaceholderElement
  constructor: (@element, options={}) ->
    @placeholder = @element.attributes['placeholder'].value
    $element = $(@element)
    $element.on 'focus', => @clearPlaceholder()
    $element.on 'blur', => @setPlaceholder()
    $element.on 'keyUp', => @supressEnterKey()
    @setPlaceholder()

  getText: () ->
    text = @element.innerText
    if text == @placeholder || text == '' then '' else text

  supressEnterKey: ->

  clearPlaceholder: ->
    if @element.innerText == @placeholder
      @element.innerText = ''
      @element.classList.remove('placeholder')

  setPlaceholder: ->
    if @element.innerText.trim() == ''
      @element.innerText = @placeholder
      @element.classList.add('placeholder')

