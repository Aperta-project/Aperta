ETahi.RedirectsIfEditable = Em.Mixin.create
  toggleEditable: ->
    if @get('controller.model.editable')
      @controller.transitionToRoute('paper.edit')
    else
      @controller.transitionToRoute('paper.index')

  setupEditableToggle: (->
    @addObserver('controller.model.editable', @, @toggleEditable)
  ).on('didInsertElement')

  teardownEditableToggle: (->
    @removeObserver('controller.model.editable', @, @toggleEditable)
  ).on('willDestroyElement')

