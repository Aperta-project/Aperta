ETahi.FigureOverlayController = ETahi.TaskController.extend
  figureUploadUrl: ( ->
    "/papers/#{@get('litePaper.id')}/figures"
  ).property('litePaper.id')

  uploads: []

  figures: Ember.computed.alias 'paper.figures'

  actions:
    uploadStarted: (data) ->
      @get('uploads').pushObject ETahi.FileUpload.create(file: data.files[0])

    uploadProgress: (data) ->
      currentUpload = @get('uploads').findBy('file', data.files[0])
      currentUpload.setProperties(dataLoaded: data.loaded, dataTotal: data.total)

    uploadFinished: (data) ->
      uploads = @get('uploads')
      newUpload = uploads.findBy('file', data.files[0])
      uploads.removeObject newUpload

      newFigures = _.map data.result.figures, (figure) =>
        @store.pushPayload 'figure', { figures: [ figure ] }
        @store.getById('figure', figure.id)

      @get('figures').pushObjects(newFigures)
