ETahi.JournalIndexRoute = Ember.Route.extend
  fetchAdminJournalUsers: (journalId) ->
    @store.find 'AdminJournalUser', journal_id: journalId
    .then (users) => @set 'controller.adminJournalUsers', users

  setupController: (controller, model) ->
    @_super controller, model
    @fetchAdminJournalUsers model.get('id')

  deactivate: -> @set 'controller.adminJournalUsers', null
