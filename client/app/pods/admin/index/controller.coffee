`import Ember from 'ember'`

AdminIndexController = Ember.ArrayController.extend Ember.PromiseProxyMixin,
  needs: ['application']
  sortProperties: ['createdAt']
  sortAscending: false
  placeholderText: "Need to find a user?<br> Search for them here."
  isCurrentUserAdmin: Ember.computed.alias 'controllers.application.currentUser.siteAdmin'

  newJournalPresent: (->
    @get('arrangedContent').any((a) -> a.get('isNew'))
  ).property('arrangedContent.@each.isNew')

  resetSearch: ->
    @set 'adminJournalUsers', null
    @set 'placeholderText', null

  actions:
    addNewJournal: ->
      return if @get('newJournalPresent')
      @store.createRecord 'adminJournal', createdAt: new Date

    searchUsers: ->
      @resetSearch()
      @store.find('AdminJournalUser', query: @get('searchQuery')).then (users) =>
        @set 'adminJournalUsers', users
        if Ember.isEmpty @get('adminJournalUsers')
          @set 'placeholderText', "No matching users found"

`export default AdminIndexController`
