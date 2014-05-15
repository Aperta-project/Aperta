ETahi.RolesRoleController = Em.ObjectController.extend
  isEditing: false

  setIsEditing: (->
    if @get('model.isNew')
      @set('isEditing', true)
  ).on('init')

  actions:
    edit: ->
      @set('isEditing', true)
    save: ->
      @set('isEditing', false)
    cancel: ->
      @get('model').rollback()
      @set('isEditing', false)

