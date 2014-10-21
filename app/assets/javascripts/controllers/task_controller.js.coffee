ETahi.TaskController = Ember.ObjectController.extend ETahi.SavesDelayed, ETahi.ControllerParticipants,
  needs: ['application']
  onClose: 'closeOverlay'
  isLoading: false
  isPaperEditDisabled: Ember.computed.not('paper.editable')
  isMetadata: Ember.computed.alias('isMetadataTask')
  isMetadataAndPaperEditDisabled: Ember.computed.and('isPaperEditDisabled', 'isMetadata')
  isUserEditable: Ember.computed.not('isMetadataAndPaperEditDisabled')
  isCurrentUserAdmin: Ember.computed.alias 'controllers.application.currentUser.admin'
  isEditable: Ember.computed.or('isUserEditable', 'isCurrentUserAdmin')

  # This will get overriden in setupController
  comments: []

  redirectStack: Ember.computed.alias 'controllers.application.overlayRedirect'
  validationErrors: {}

  clearCachedModel: (transition) ->
    redirectStack = @get('redirectStack')
    if !Em.isEmpty(redirectStack)
      redirectRoute = redirectStack.popObject()
      unless transition.targetName == redirectRoute.get('firstObject')
        @get('controllers.application').set('cachedModel', null)

  saveModel: ->
    @_super()
      .then () =>
        @set('validationErrors', {})
      .catch (error) =>
        @set('model.completed', false)
        @set('validationErrors', Tahi.utils.camelizeKeys(error.errors))

  associatedErrors: (model) ->
    @validationErrorsForType(model)[model.get('id')]

  clearErrors: (model) ->
    delete @validationErrorsForType(model)[model.get('id')]

  validationErrorsForType: (model) ->
    errorKey = model.get('constructor.typeKey').pluralize()
    @get('validationErrors')[errorKey] || {}

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
