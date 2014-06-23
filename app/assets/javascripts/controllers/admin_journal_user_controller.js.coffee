ETahi.AdminJournalUserController = Ember.ObjectController.extend
  modalId: (->
    "#{@get('id')}-#{@get('username')}"
  ).property('username', 'id')

  actions:
    saveUser: ->
      @get('model').save()

    rollbackUser: ->
      @get('model').rollback()
