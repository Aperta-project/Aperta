`import Ember from 'ember'`

AdminIndexController = Ember.ArrayController.extend Ember.PromiseProxyMixin,
  needs: ['application']
  sortProperties: ['createdAt']
  sortAscending: false
  placeholderText: "Need to find a user?<br> Search for them here."
  isCurrentUserAdmin: Ember.computed.alias 'controllers.application.currentUser.siteAdmin'

  resetSearch: ->
    @set 'adminJournalUsers', null
    @set 'placeholderText', null

  actions:
    addNewJournal: ->
      @store.createRecord 'adminJournal', createdAt: new Date

    searchUsers: ->
      @resetSearch()
      @store.find('AdminJournalUser', query: @get('searchQuery')).then (users) =>
        @set 'adminJournalUsers', users
        if Ember.isEmpty @get('adminJournalUsers')
          @set 'placeholderText', "No matching users found"

`export default AdminIndexController`
