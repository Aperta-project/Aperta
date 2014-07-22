ETahi.IndexController = Ember.ObjectController.extend
  needs: ['application']

  currentUser: Ember.computed.alias 'controllers.application.currentUser'

  hasPapers: Ember.computed.notEmpty('model.papers')

  pageNumber: 2

  actions:
    loadMorePapers: ->
      @store.find('lite_paper', page_number: @get('pageNumber'))
        .then (litePapers) =>
          @get('model.papers').pushObjects(litePapers)
          @set('pageNumber', @get('pageNumber') + 1)
