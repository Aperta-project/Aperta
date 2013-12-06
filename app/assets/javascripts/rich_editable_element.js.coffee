window.Tahi ||= {}

class Tahi.RichEditableElement
  constructor: (@element) ->
    @instance = CKEDITOR.inline @element,
      extraPlugins: 'sharedspace'
      removePlugins: 'floatingspace,resize'
      sharedSpaces:
        top: 'toolbar'
      toolbar: [
        [ 'Format' ]
        [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ]
        [ 'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', 'Table' ]
        [ 'PasteFromWord' ],
        [ 'Link', 'Unlink' ]
        [ 'Replace' ]
      ]
      format_tags: 'h2;h3;h4;h5;h6;p;div;pre;address'
      disableNativeSpellChecker: false

    @placeholderText = @element.attributes['placeholder'].value
    @setPlaceholder()
    @instance.on 'focus', => @clearPlaceholder()
    @instance.on 'blur', => @setPlaceholder()

  getText: ->
    text = $($.parseHTML(@instance.getData())).text().trim()
    if text == @placeholderText || text == '' then '' else text

  setPlaceholder: ->
    text = $($.parseHTML(@instance.getData())).text().trim()
    if text == '' || text == @placeholderText
      @instance.element.addClass 'placeholder'
      @instance.setData @placeholderText

  clearPlaceholder: ->
    text = $($.parseHTML(@instance.getData())).text().trim()
    if text == @placeholderText
      @instance.element.removeClass 'placeholder'
      @instance.setData ''
