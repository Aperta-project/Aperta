ETahi.TaskController = Ember.ObjectController.extend ETahi.SavesDelayed, ETahi.ControllerParticipants,
  needs: ['application']
  onClose: 'closeOverlay'
  isLoading: false
  isPaperSubmitted: Ember.computed.alias('litePaper.submitted')
  isMetadata: Ember.computed.alias('isMetadataTask')
  isMetadataAndSubmitted: Ember.computed.and('isPaperSubmitted', 'isMetadata')
  isUserEditable: Ember.computed.not('isMetadataAndSubmitted')
  isCurrentUserAdmin: Ember.computed.alias 'controllers.application.currentUser.admin'
  isEditable: Ember.computed.or('isUserEditable', 'isCurrentUserAdmin')

  redirectStack: Ember.computed.alias 'controllers.application.overlayRedirect'

  clearCachedModel: (transition) ->
    redirectStack = @get('redirectStack')
    if !Em.isEmpty(redirectStack)
      redirectRoute = redirectStack.popObject()
      unless transition.targetName == redirectRoute.get('firstObject')
        @get('controllers.application').set('cachedModel', null)

  actions:
    #saveModel is implemented in ETahi.SavesDelayed

    closeAction: ->
      @send(@get('onClose'))

    redirect: ->
      @transitionToRoute.apply(this, @get('controllers.application.overlayRedirect.lastObject'))

    redirectToDashboard: ->
      @transitionToRoute 'index'

    postComment: (body) ->
      return unless body
      commenter = @getCurrentUser()
      commentFields =
        commenter: commenter
        task: @get('model')
        body: body
        createdAt: new Date()
      newComment = @store.createRecord('comment', commentFields)
      newComment.save()

    routeWillTransition: (transition) ->
      if @get('isUploading')
        if confirm 'You are uploading, are you sure you want to cancel?'
          @send('cancelUploads')
        else
          transition.abort()
          return

      @clearCachedModel(transition)
