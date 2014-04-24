ETahi.ManuscriptManagerTemplateEditView = Em.View.extend
  actions:
    cancelEdit: ->
      @get('controller').send('rollbackTemplate')
