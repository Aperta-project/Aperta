`import Ember from 'ember'`

AdminJournalUserController = Ember.Controller.extend
  needs: ['admin/journal/index']

  journalRoles: Ember.computed.alias 'controllers.admin/journal/index.model.roles'
  userJournalRoles: Ember.computed.mapBy('model.userRoles', 'role')

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

`export default AdminJournalUserController`
