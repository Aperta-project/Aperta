ETahi.CompetingInterestsOverlayController = ETahi.TaskController.extend
  onClose: "saveAndClose"

  actions:
    saveAndClose: ->
      records = @get('model.questions').map (q) ->
        if q.get('isNew') or q.get('isDirty')
           q.save()
      Ember.RSVP.all(records).then =>
        @get('model').save().then =>
          @send('closeOverlay')
