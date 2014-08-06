ETahi.IndexController = Ember.ObjectController.extend Ember.Evented,
  needs: ['application']

  currentUser: Ember.computed.alias 'controllers.application.currentUser'

  hasPapers: Ember.computed.notEmpty('model.papers')

  pageNumber: 1

  paginate: (->
    @get('pageNumber') isnt @get('totalPageCount')
  ).property('totalPageCount', 'pageNumber')

  actions:
    loadMorePapers: ->
      @store.find 'lite_paper', page_number: (@get('pageNumber') + 1)
      .then (litePapers) =>
        @get('model.papers').pushObjects litePapers
        @incrementProperty 'pageNumber'
        @trigger('papersDidLoad')
