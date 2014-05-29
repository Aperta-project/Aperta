ETahi.AuthorsOverlayController = ETahi.TaskController.extend
  resolvedPaper: null

  _setPaper: ( ->
    @get('paper').then (paper) =>
      @set('resolvedPaper', paper)
  ).observes('paper')

  lastAuthorGroup: Ember.computed.alias('resolvedPaper.authorGroups.lastObject')
  canDeleteLastGroup: Ember.computed.empty('lastAuthorGroup.authors.[]')

  actions:
    addAuthorGroup: ->
      newAuthorGroup = @store.createRecord('authorGroup')
      newAuthorGroup.set('paper', @get('resolvedPaper'))
      newAuthorGroup.save()

    removeAuthorGroup: ->
      if @get('canDeleteLastGroup')
        @get('lastAuthorGroup').destroyRecord()
