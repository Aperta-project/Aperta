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
      @get('model').save()
    cancel: ->
      @set('isEditing', false)
      if @get('model.isNew')
        @get('model').deleteRecord()
      else
        @get('model').rollback()
    delete: ->
      @send('deleteRole', @get('model'))

