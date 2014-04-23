ETahi.ManuscriptManagerTemplateEditView = Em.View.extend
  editMode: false

  actions:
    cancelEdit: ->
      @set('editMode', false)
      @get('controller').send('rollbackTemplate')

    startEdit: ->
      @set('editMode', true)
