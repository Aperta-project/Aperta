ETahi.FeedbackController = Ember.ObjectController.extend
  overlayClass: 'overlay--fullscreen feedback-overlay'
  screenshots: []

  setupModel: (->
    @resetModel()
    @set('model.referrer', window.location)
  ).on('init')

  actions:
    submit: ->
      @get('model').save().then (feedback) =>
        thanks = $("<div class='overlay-content minimal thanks'>We've got it. Thank you.</div>")
        $(".overlay-container").html(thanks)
        @resetModel()

    closeAction: ->
      @send('closeOverlay')

    uploadFinished: (data, filename) ->
      @get('model.screenshots').pushObject({url: data, filename: filename})

  resetModel: ->
    @set('model', @store.createRecord('feedback'))
