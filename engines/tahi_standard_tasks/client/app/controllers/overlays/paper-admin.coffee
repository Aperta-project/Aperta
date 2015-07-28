`import TaskController from 'tahi/pods/paper/task/controller'`
`import Select2Assignees from 'tahi/mixins/controllers/select-2-assignees'`

PaperAdminOverlayController = TaskController.extend Select2Assignees,
  select2RemoteUrl: Ember.computed 'model.paper', ->
    "/api/filtered_users/admins/#{@get 'model.paper.id' }/"

  selectedTemplate: (user) ->
    # Handle raw object or ember model
    if typeof(user.email) is "string"
      user.email
    else
      user.get('email')

  actions:
    assignAdmin: (select2User) ->
      @store.find('user', select2User.id).then (user) =>
        @set('model.admin', user)
        @send('saveModel')

`export default PaperAdminOverlayController`
