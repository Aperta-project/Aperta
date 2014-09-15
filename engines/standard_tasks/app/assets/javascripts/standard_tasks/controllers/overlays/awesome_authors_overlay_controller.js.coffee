ETahi.AwesomeAuthorsOverlayController = ETahi.TaskController.extend
  resolvedPaper: null

  _setPaper: ( ->
    @get('paper').then (paper) =>
      @set('resolvedPaper', paper)
  ).observes('paper')

  actions:
    saveAuthor: ->
      @sendAction('save', @get('awesomeAuthor'))
