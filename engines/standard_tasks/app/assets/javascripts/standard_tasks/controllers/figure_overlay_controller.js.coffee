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

    uploadFinished: (data, filename) ->
      uploads = @get('uploads')
      newUpload = uploads.findBy('file.name', filename)
      uploads.removeObject newUpload

      @store.pushPayload('figure', data)
      figure = @store.getById('figure', data.figure.id)

      @get('figures').pushObject(figure)

    changeStrikingImage: (newValue) ->
      @get('content.paper').then (paper)->
        paper.set('strikingImage', newValue).save()
