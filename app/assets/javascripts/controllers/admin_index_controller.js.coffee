ETahi.AdminIndexController = Ember.ArrayController.extend
  actions:
    addNewJournal: ->
      @store.createRecord 'adminJournal', logoUrl: '/assets/no-journal-image.gif'
