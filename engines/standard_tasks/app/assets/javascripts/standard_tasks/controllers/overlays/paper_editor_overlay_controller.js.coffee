ETahi.PaperEditorOverlayController = ETahi.TaskController.extend ETahi.Select2Assignees,
  select2RemoteUrl: Ember.computed 'paper.journal.id', ->
    "/filtered_users/editors/#{@get('model.paper.journal.id')}/"

  actions:
    assignEditor: (select2Editor) ->
      @store.find('user', select2Editor.id).then (user) =>
        @set('editor', user)
        @send('saveModel')
