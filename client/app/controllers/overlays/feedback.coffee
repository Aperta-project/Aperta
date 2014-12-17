`import Ember from 'ember'`

FeedbackController = Ember.ObjectController.extend
  overlayClass: 'overlay--fullscreen feedback-overlay'

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

  resetModel: ->
    @set('model', @store.createRecord('feedback'))

`export default FeedbackController`
