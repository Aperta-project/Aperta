ETahi.PaperAdminOverlayController = ETahi.TaskController.extend ETahi.Select2Assignees,
  select2RemoteUrl: Ember.computed 'paper.journal.id', ->
    "/filtered_users/admins/#{@get('model.paper.journal.id')}/"

  actions:
    assignAdmin: (select2User) ->
      @store.find('user', select2User.id).then (user) =>
        @set('admin', user)
        @send('saveModel')
