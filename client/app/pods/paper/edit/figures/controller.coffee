`import Ember from 'ember'`
`import FileUploadMixin from 'tahi/mixins/file-upload'`

EditFiguresController = Ember.Controller.extend FileUploadMixin,
  # initialized via paper/edit/route
  paper: Ember.computed.alias('model')

  # intitialized via template
  toolbar: null

  needs: ['paper/edit']
  manuscriptEditor: Ember.computed.alias('controllers.paper/edit.editor')

  figures: ( ->
    figures = @get('paper.figures') || []
    figures.sortBy('createdAt').reverse()
  ).property('paper.figures.[]')

  figureUploadUrl: ( ->
    "/api/papers/#{@get('paper.id')}/figures"
  ).property('paper.id')

  actions:

    updateToolbar: (newState)->
      toolbar = @get('toolbar');
      if toolbar
        lastState = @get('lastState')
        if not lastState or newState.hasSelection() or lastState.editor == newState.editor
          # skip if the update is due to a blur while another editor has been focused already
          toolbar.updateState(newState);
          @set('lastState', newState)

    uploadFinished: (data, filename) ->
      @uploadFinished(data, filename)

      @store.pushPayload('figure', data)
      figure = @store.getById('figure', data.figure.id)

      @get('paper.figures').pushObject(figure)

    changeStrikingImage: (newValue) ->
      @get('paper').set('strikingImageId', newValue).save()

    destroyAttachment: (attachment) ->
      @get('paper.figures').removeObject(attachment)
      attachment.destroyRecord()

`export default EditFiguresController`
