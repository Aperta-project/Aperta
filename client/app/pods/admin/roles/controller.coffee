`import Ember from 'ember'`

RolesIndexController = Ember.ArrayController.extend
  needs: ['admin/journal']
  journal: Ember.computed.alias('controllers.journal.model')

  actions:
    addRole: ->
      role = @store.createRecord('role')
      @get('content').unshiftObject(role)
    deleteRole: (role) ->
      # FIXME: rollback if there was an error deleting a role
      role.destroyRecord()

`export default RolesIndexController`
