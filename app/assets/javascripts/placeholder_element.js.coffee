window.Tahi ||= {}

class Tahi.PlaceholderElement
  constructor: (@element, options={}) ->
    @placeholder = @element.attributes['placeholder'].value
    $element = $(@element)
    $element.on 'focus', => @clearPlaceholder()
    $element.on 'blur', => @setPlaceholder()
    $element.on 'keydown', (e) => @supressEnterKey(e)
    @setPlaceholder()

  getText: () ->
    text = @element.textContent
    if text == @placeholder || text == '' then '' else text

  supressEnterKey: (e) ->
    if e.keyCode == 13 || e.which == 13
      e.preventDefault()

  clearPlaceholder: ->
    if @element.textContent == @placeholder
      @element.textContent = ''
      @element.classList.remove('placeholder')

  setPlaceholder: ->
    if @element.textContent.trim() == ''
      @element.textContent = @placeholder
      @element.classList.add('placeholder')

