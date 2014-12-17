`import Ember from 'ember'`
`import SavesDelayed from 'tahi/mixins/controllers/saves-delayed'`
`import ControllerParticipants from 'tahi/mixins/controllers/controller-participants'`
`import ValidatesAssociatedModels from 'tahi/mixins/controllers/validates-associated-models'`

TaskController = Ember.ObjectController.extend SavesDelayed, ControllerParticipants, ValidatesAssociatedModels, Ember.Evented,
  queryParams: ['isNewTask']
  isNewTask: false
  needs: ['application']
  onClose: 'closeOverlay'
  isLoading: false
  isMetadata: Ember.computed.alias('isMetadataTask')
  isUserEditable: Ember.computed 'paper.editable', 'isMetadata', ->
    @get('paper.editable') || !@get('isMetadata')

  isCurrentUserAdmin: Ember.computed.alias 'controllers.application.currentUser.siteAdmin'
  isEditable: Ember.computed.or('isUserEditable', 'isCurrentUserAdmin')

  # This will get overridden in setupController
  comments: []

  redirectStack: Ember.computed.alias 'controllers.application.overlayRedirect'

  clearCachedModel: (transition) ->
    redirectStack = @get('redirectStack')
    if !Ember.isEmpty(redirectStack)
      redirectRoute = redirectStack.popObject()
      unless transition.targetName == redirectRoute.get('firstObject')
        @get('controllers.application').set('cachedModel', null)

  saveModel: ->
    @_super()
      .then () =>
        @clearValidationErrors()
      .catch (error) =>
        @setValidationErrors(error.errors)
        @set('model.completed', false)

  actions:

    closeAction: ->
      @send(@get('onClose'))

    redirect: ->
      @transitionToRoute.apply(this, @get('controllers.application.overlayRedirect.lastObject'))

    redirectToDashboard: ->
      @transitionToRoute 'index'

    postComment: (body) ->
      return unless body
      commentFields =
        commenter: @currentUser
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

`export default TaskController`
