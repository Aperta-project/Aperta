class Tahi.RichEditableElement
  constructor: (@element) ->
    @instance = CKEDITOR.inline @element,
      extraPlugins: 'sharedspace,save_button'
      removePlugins: 'floatingspace,resize'
      sharedSpaces:
        top: 'toolbar'
      toolbar: [
        [ 'TahiSave' ]
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
    editorData = @instance.getData()
    text = $($.parseHTML(editorData)).text().trim()
    if text == @placeholderText || text == '' then '' else editorData

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
