ETahi.RedirectsIfEditable = Em.Mixin.create
  toggleEditable: ->
    @get('controller').send('editableDidChange')

  setupEditableToggle: (->
    @addObserver('controller.model.editable', @, @toggleEditable)
  ).on('didInsertElement')

  teardownEditableToggle: (->
    @removeObserver('controller.model.editable', @, @toggleEditable)
  ).on('willDestroyElement')
