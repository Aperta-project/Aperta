`import Ember from 'ember'`

IndexController = Ember.Controller.extend
  needs: ['application']
  papers: null
  unreadComments: [] # will be set in setupController
  invitations: []

  currentUser: Ember.computed.alias 'controllers.application.currentUser'

  hasPapers: Ember.computed.notEmpty('papers')

  relatedAtSort: ['relatedAtDate:desc']
  sortedPapers: Ember.computed.sort('papers', 'relatedAtSort')

  pageNumber: 1

  paginate: (->
    @get('pageNumber') isnt @get('model.totalPageCount')
  ).property('model.totalPageCount', 'pageNumber')

  actions:
    loadMorePapers: ->
      @store.find 'paper', page_number: (@get('pageNumber') + 1)
      .then (papers) =>
        @incrementProperty 'pageNumber'

`export default IndexController`
