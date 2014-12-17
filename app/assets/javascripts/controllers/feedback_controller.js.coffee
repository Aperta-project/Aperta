ETahi.FeedbackController = Ember.ObjectController.extend
  overlayClass: 'overlay--fullscreen feedback-overlay'
  feedbackSubmitted: false
  isUploading: false

  setupModel: (->
    @resetModel()
    @set('model.referrer', window.location)
    @set('model.screenshots', [])
  ).on('init')

  actions:
    submit: ->
      @get('model').save().then (feedback) =>
        @set('feedbackSubmitted', true)
        @resetModel()

    closeAction: ->
      @send('closeOverlay')
      @set('feedbackSubmitted', false)

    uploadFinished: (data, filename) ->
      @set('isUploading', false)
      @get('model.screenshots').pushObject({url: data, filename: filename})

    uploadStarted: (data, filename) ->
      @set('isUploading', true)

    removeScreenshot: (screenshot) ->
      @get('model.screenshots').removeObject(screenshot)

  resetModel: ->
    @set('model', @store.createRecord('feedback'))
