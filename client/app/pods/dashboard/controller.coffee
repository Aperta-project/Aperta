`import Ember from 'ember'`

IndexController = Ember.Controller.extend
  papers: []
  invitations: []
  unreadComments: []

  hasPapers: Ember.computed.notEmpty('papers')

  relatedAtSort: ['relatedAtDate:desc']
  sortedPapers: Ember.computed.sort('papers', 'relatedAtSort')

  pageNumber: 1

  canLoadMore: (->
    @get('pageNumber') isnt @store.metadataFor("paper").total_pages
  ).property('pageNumber')

  actions:
    loadMorePapers: ->
      @store.find 'paper', page_number: (@get('pageNumber') + 1)
      .then (papers) =>
        @incrementProperty 'pageNumber'

`export default IndexController`
