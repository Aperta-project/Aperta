ETahi.FigureOverlayController = ETahi.TaskController.extend
  figureUploadUrl: ( ->
    "/papers/#{@get('paper.id')}/figures"
  ).property('paper.id')

  uploads: []

  figures: Ember.computed.alias 'paper.figures'

  actions:
    processFigure: (data) ->
      @get('uploads').pushObject ETahi.FigureUpload.create(file: data.files[0])

    uploadProgress: (data) ->
      currentUpload = @get('uploads').findBy('filename', data.files[0].name)
      progress = parseInt(data.loaded / data.total * 100.0, 10) #rounds the number
      currentUpload.set('progress', progress)

    figureUploaded: (data) ->
      uploads = @get('uploads')
      newUpload = uploads.findBy('filename', data.files[0].name)
      uploads.removeObject newUpload

      _.map data.result.figures, (figure) =>
        @store.pushPayload 'figure', { figures: [ figure ] }
        newFigure = @store.getById('figure', figure.id)
        @get('figures').pushObject(newFigure)
