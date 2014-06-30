ETahi.TaskController = Ember.ObjectController.extend ETahi.SavesDelayed,
  needs: ['application']
  onClose: 'closeOverlay'
  isLoading: false

  isPaperSubmitted: Ember.computed.alias('litePaper.submitted')
  isMetadata: Ember.computed.alias('isMetadataTask')
  isMetadataAndSubmitted: Ember.computed.and('isPaperSubmitted', 'isMetadata')
  isUserEditable: Ember.computed.not('isMetadataAndSubmitted')
  isCurrentUserAdmin: Ember.computed.alias 'controllers.application.currentUser.admin'

  isEditable: Ember.computed.or('isUserEditable', 'isCurrentUserAdmin')

  actions:
    #saveModel is implemented in ETahi.SavesDelayed

    closeAction: ->
      @send(@get('onClose'))

    redirect: ->
      @transitionToRoute.apply(this, @get('controllers.application.overlayRedirect').popObject())
