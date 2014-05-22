ETahi.RolesShowController = Em.ObjectController.extend
  isEditing: false

  setIsEditing: (->
    if @get('model.isNew')
      @set('isEditing', true)
  ).on('init')

  actions:
    edit: ->
      @set('isEditing', true)
    save: ->
      @get('model').save().then(
        => @set('isEditing', false)
      ).catch -> # ignore 422. we're displaying errors

    cancel: ->
      @set('isEditing', false)
      if @get('model.isNew')
        @get('model').deleteRecord()
      else
        @get('model').rollback()
    delete: ->
      @send('deleteRole', @get('model'))

