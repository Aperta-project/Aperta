ETahi.PaperEditorOverlayController = ETahi.TaskController.extend
  editorSelectRemoteSource: (->
    url: "/filtered_users/editors/#{@get('model.paper.journal.id')}/"
    dataType: "json"
    quietMillis: 500
    data: (term) ->
      query: term
    results: (data) =>
      results: data.filtered_users
  ).property()

  resultsTemplate: (user) ->
    user.full_name

  selectedTemplate: (user) =>
    user.full_name || user.get('fullName')

  actions:
    assignEditor: (select2Editor) ->
      @store.find('user', select2Editor.id).then (user) =>
        @set('editor', user)
        @send('saveModel')

