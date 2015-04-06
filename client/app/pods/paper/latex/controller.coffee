`import Ember from 'ember'`
`import BasePaperController from 'tahi/controllers/base-paper'` # EMBERCLI TODO - this is weird

Controller = BasePaperController.extend

  locked: ( ->
    !Ember.isBlank(@get('processingMessage') || @get('userEditingMessage'))
  ).property('processingMessage', 'userEditingMessage')

  isEditing: (->
    lockedBy = @get('lockedBy')
    lockedBy and lockedBy is @currentUser
  ).property('lockedBy')

  canEdit: ( ->
    !@get('locked')
  ).property('locked')

  startEditing: ->
    @set('lockedBy', @currentUser)
    @get('model').save().then (paper) =>
      @send('startEditing')
      @set('saveState', false)

  stopEditing: ->
    # @set('model.body', @get('editor').toHtml())
    @set('lockedBy', null)
    @send('stopEditing')
    @get('model').save().then (paper) =>
      @set('saveState', true)

  actions:
    toggleEditing: ->
      if @get('lockedBy') #unlocking -> Allowing others to edit
        @stopEditing()
      else #locking -> Editing Paper (locking others out)
        @startEditing()

`export default Controller`
