ETahi.AuthorsOverlayController = ETahi.TaskController.extend
  resolvedPaper: null

  _setPaper: ( ->
    @get('paper').then (paper) =>
      @set('resolvedPaper', paper)
  ).observes('paper')

  actions:
    addAuthorGroup: ->
      newAuthorGroup = @store.createRecord('authorGroup', {})
      newAuthorGroup.set('paper', @get('resolvedPaper'))
      newAuthorGroup.save()

    removeAuthorGroup: ->
      lastAuthorGroup = @get('resolvedPaper.authorGroups.lastObject')
      if !lastAuthorGroup.get('authors.length')
        lastAuthorGroup.destroyRecord()
