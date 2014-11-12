ETahi.PaperReviewerOverlayController = ETahi.TaskController.extend ETahi.Select2Assignees,
  select2RemoteUrl: Ember.computed 'paper.journal.id', ->
    "/filtered_users/reviewers/#{@get('model.paper.journal.id')}/"

  actions:
    addReviewer: (select2User) ->
      @store.find('user', select2User.id).then (user) =>
        @get('reviewers').addObject(user)
        @send('saveModel')

    removeReviewer: (select2User) ->
      @store.find('user', select2User.id).then (user) =>
        @get('reviewers').removeObject(user)
        @send('saveModel')
