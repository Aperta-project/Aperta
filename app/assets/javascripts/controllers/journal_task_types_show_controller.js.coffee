ETahi.JournalTaskTypesShowController = Em.ObjectController.extend
  needs: ['journal']
  journal: Ember.computed.alias('controllers.journal')

  isEditing: false
  notEditing: Ember.computed.not('isEditing')

  taskTypeSort: ['name: asc']
  availableTaskRoles: Ember.computed.sort('journal.roles', 'taskTypeSort')

  observeTitle: (->
    if @get('model').changedAttributes().title
      @set('isEditing', true)
  ).observes('model.title')

  actions:
    updateRole: ->
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


