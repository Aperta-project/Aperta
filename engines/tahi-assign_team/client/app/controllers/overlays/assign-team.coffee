`import Ember from 'ember'`
`import ValidationErrorsMixin from 'tahi/mixins/validation-errors'`
`import TaskController from 'tahi/pods/paper/task/controller'`

AssignTeamTaskController = TaskController.extend ValidationErrorsMixin,
  fetchRoles: (->
    Ember.$.getJSON "/api/papers/#{@model.get('paper.id')}/roles", (data) =>
      @set 'roles', data.roles
  ).on('didSetupController')

  isAssignable: Em.computed ->
    false

  fetchUsers: (->
    Ember.$.getJSON "/api/papers/#{@model.get('paper.id')}/roles/#{@get('selectedRole').id}/users", (data) =>
      @set 'users', data.users
  ).observes('selectedRole')

  selectableRoles: (->
    roles = @get('roles') or []

    roles.map (role) ->
      id: role.id
      text: role.name
  ).property('roles')

  selectableUsers: (->
    users = @get('users') or []

    users.map (user) ->
      id: user.id
      text: user.full_name
  ).property('users')

  actions:
    destroyAssignment: (assignment)->
      assignment.destroyRecord()

    assignRoleToUser: ->
      @store.find('user', @get('selectedUser').id).then (user) =>
        assignment = @store.createRecord 'assignment',
          user: user
          paper: @model.get('paper')
          role: @get('selectedRole').text
        assignment.save()
          .then =>
            @model.get('assignments').pushObject(assignment)
          .catch (response) =>
            @displayValidationErrorsFromResponse response

    didSelectRole: (role) ->
      @set 'selectedRole', role

    didSelectUser: (user) ->
      @set 'selectedUser', user
      @set 'isAssignable', true

`export default AssignTeamTaskController`
