ETahi.RedirectsIfEditable = Em.Mixin.create
  editable: Ember.computed.alias('controller.model.editable')

  supportedDownloadFormats: Ember.computed ->
    # TODO move this to ember data
    $.getJSON('/formats', (data) ->
      console.log('data', data)
      window.ETahi.supportedDownloadFormats = data
    )
    if ETahi.supportedDownloadFormats
      exportFormats = ETahi.supportedDownloadFormats.export_formats
      for dataType in exportFormats
        dataType.icon = "svg/#{dataType.format}-icon"
      exportFormats

  toggleEditable: ->
    if @get('editable') != @get('lastEditable')
      @set('lastEditable', @get('editable'))
      @get('controller').send('editableDidChange')

  setupEditableToggle: (->
    @set('lastEditable', @get('editable'))
    @addObserver('editable', @, @toggleEditable)
  ).on('didInsertElement')

  teardownEditableToggle: (->
    @removeObserver('editable', @, @toggleEditable)
  ).on('willDestroyElement')
