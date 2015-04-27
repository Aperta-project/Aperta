`import Ember from 'ember'`
`import Utils from 'tahi/services/utils'`
`import BasePaperController from 'tahi/controllers/base-paper'` # EMBERCLI TODO - this is weird

Controller = BasePaperController.extend

  renderedLatexUrl: ( ->
    id = @get('compiledId')
    height = 300 + Math.floor(Math.random() * 50)
    "http://placekitten.com/g/200/#{height}?#{id}"
  ).property('compiledId')

  compiledId: Utils.generateUUID()

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

  stopEditing: ->
    @set('lockedBy', null)
    @send('stopEditing')
    @savePaper()

  savePaper: ->
    return unless @get('model.editable')
    return unless @get('model.isDirty')
    @get('model').save()
    renderUrl = "/api/papers/#{@get('model.id')}/fake_render_latex"
    # post data to our latex service
    $.post(renderUrl, latexContent: @get('model.body')).then =>
      @set('compiledId', Utils.generateUUID())

  savePaperDebounced: (->
    Ember.run.debounce(@, @savePaper, 2000)
  ).observes('model.body')

  actions:
    toggleEditing: ->
      if @get('lockedBy') #unlocking -> Allowing others to edit
        @stopEditing()
      else #locking -> Editing Paper (locking others out)
        @startEditing()

`export default Controller`
