`import TaskController from 'tahi/pods/task/controller'`
`import Select2Assignees from 'tahi/mixins/controllers/select-2-assignees'`

PaperAdminOverlayController = TaskController.extend Select2Assignees,
  select2RemoteUrl: Ember.computed 'model.paper', ->
    "/filtered_users/admins/#{@get 'model.paper.id' }/"

  actions:
    assignAdmin: (select2User) ->
      @store.find('user', select2User.id).then (user) =>
        @set('admin', user)
        @send('saveModel')

`export default PaperAdminOverlayController`
