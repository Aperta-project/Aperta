ETahi.ManuscriptManagerTemplateEditView = Em.View.extend
  editMode: false

  actions:
    cancelEdit: ->
      @set('editMode', false)

    startEdit: ->
      @set('editMode', true)
