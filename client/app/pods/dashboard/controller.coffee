`import Ember from 'ember'`

IndexController = Ember.ObjectController.extend
  needs: ['application']
  papers: null
  unreadComments: [] # will be set in setupController

  currentUser: Ember.computed.alias 'controllers.application.currentUser'

  hasPapers: Ember.computed.notEmpty('papers')

  relatedAtSort: ['relatedAtDate:desc']
  sortedPapers: Ember.computed.sort('papers', 'relatedAtSort')

  pendingInvitations: Ember.computed.filterBy('invitations', 'state', 'pending')

  pageNumber: 1

  paginate: (->
    @get('pageNumber') isnt @get('totalPageCount')
  ).property('totalPageCount', 'pageNumber')

  actions:
    loadMorePapers: ->
      @store.find 'lite_paper', page_number: (@get('pageNumber') + 1)
      .then (litePapers) =>
        @incrementProperty 'pageNumber'

`export default IndexController`
