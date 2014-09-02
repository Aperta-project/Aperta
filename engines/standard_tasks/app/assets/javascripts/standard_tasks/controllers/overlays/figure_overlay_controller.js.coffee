ETahi.FigureOverlayController = ETahi.TaskController.extend
  needs: ['fileUpload'],
  figureUploadUrl: ( ->
    "/papers/#{@get('litePaper.id')}/figures"
  ).property('litePaper.id')

  uploads: []
  isUploading: Em.computed.notEmpty('uploads')

  figures: Ember.computed.alias 'paper.figures'

  actions:
    uploadStarted: (data, fileUploadXHR) ->
      @get('controllers.fileUpload').send('uploadStarted', data, fileUploadXHR)
      @get('uploads').pushObject ETahi.FileUpload.create(file: data.files[0])

    uploadProgress: (data) ->
      @get('controllers.fileUpload').send('uploadProgress', data)
      currentUpload = @get('uploads').findBy('file', data.files[0])
      return unless currentUpload
      currentUpload.setProperties(dataLoaded: data.loaded, dataTotal: data.total)

    uploadFinished: (data, filename) ->
      @get('controllers.fileUpload').send('uploadFinished', data, filename)
      uploads = @get('uploads')
      newUpload = uploads.findBy('file.name', filename)
      uploads.removeObject newUpload

      @store.pushPayload('figure', data)
      figure = @store.getById('figure', data.figure.id)

      @get('figures').pushObject(figure)

    cancelUploads: ->
      @get('controllers.fileUpload').send('cancelUploads')
      @set('uploads', [])

    changeStrikingImage: (newValue) ->
      @get('content.paper').then (paper)->
        paper.set('strikingImageId', newValue).save()
