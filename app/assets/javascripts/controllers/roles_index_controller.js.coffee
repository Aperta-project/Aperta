ETahi.RolesIndexController = Ember.ArrayController.extend
  actions:
    addRole: ->
      role = @store.createRecord('role')
      @get('content').unshiftObject(role)
    deleteRole: (role) ->
      role.deleteRecord()
      @get('content').removeObject(role)
