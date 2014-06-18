ETahi.AdminIndexController = Ember.ArrayController.extend
  actions:
    searchUsers: ->
      @store.find('adminJournalUser', {query: @get('searchQuery')})
