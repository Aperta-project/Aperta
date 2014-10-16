ETahi.AdminIndexController = Ember.ArrayController.extend
  needs: ['admin']
  isLoading: Em.computed.alias('controllers.admin.isLoading')
  model: Em.computed.alias('controllers.admin.model')
  sortProperties: ['createdAt']
  sortAscending: false
  placeholderText: "Need to find a user?<br> Search for them here."
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
