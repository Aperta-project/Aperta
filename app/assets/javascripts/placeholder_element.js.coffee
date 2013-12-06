window.Tahi ||= {}

class Tahi.PlaceholderElement
  constructor: (@element) ->
    @placeholder = @element.attributes['placeholder'].value
    $element = $(@element)
    $element.on 'focus', => @clearPlaceholder()
    $element.on 'blur', => @setPlaceholder()
    @setPlaceholder()

  getText: () ->
    text = @element.innerText
    if text == @placeholder || text == '' then '' else text

  clearPlaceholder: ->
    if @element.innerText == @placeholder
      @element.innerText = ''
      @element.classList.remove('placeholder')

  setPlaceholder: ->
    if @element.innerText.trim() == ''
      @element.innerText = @placeholder
      @element.classList.add('placeholder')

