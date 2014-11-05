ETahi.AdminIndexController = Ember.ArrayController.extend Ember.PromiseProxyMixin,
  sortProperties: ['createdAt']
  sortAscending: false
  placeholderText: "Need to find a user?<br> Search for them here. <br><br>Want to list all users? Click the search icon with an empty search box."
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
        if Em.isEmpty @get('adminJournalUsers')
          @set 'placeholderText', "No matching users found"
