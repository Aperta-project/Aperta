ETahi.AdminJournalUserController = Ember.ObjectController.extend
  needs: ['journalIndex']

  journalRoles: Em.computed.alias 'controllers.journalIndex.model.roles'
  userJournalRoles: Em.computed.mapBy('model.userRoles', 'role')

  selectableJournalRoles: (->
    @get('journalRoles').map (jr) ->
      id: jr.get('id')
      text: jr.get('name')
  ).property('journalRoles')

  selectableUserJournalRoles: (->
    @get('userJournalRoles').map (jr) ->
      id: jr.get('id')
      text: jr.get('name')
  ).property('userJournalRoles')

  actions:
    removeRole: (roleObj) ->
      @get('model.userRoles').findBy('role.id', roleObj.id).destroyRecord()

    assignRole: (roleObj) ->
      userRole = @store.createRecord 'userRole',
        user: @get 'model'
        role: @store.getById('role', roleObj.id)
      userRole.save()
