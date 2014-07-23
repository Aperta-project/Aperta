ETahi.IndexController = Ember.ObjectController.extend
  needs: ['application']

  currentUser: Ember.computed.alias 'controllers.application.currentUser'

  hasPapers: Ember.computed.notEmpty('model.papers')

  pageNumber: 1

  paginate: Em.computed 'totalPageCount', 'pageNumber', ->
    @get('pageNumber') isnt @get('totalPageCount')

  actions:
    loadMorePapers: ->
      @store.find 'lite_paper', page_number: (@get('pageNumber') + 1)
      .then (litePapers) =>
        @get('model.papers').pushObjects litePapers
        @incrementProperty 'pageNumber'
