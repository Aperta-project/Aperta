ETahi.FigureOverlayController = ETahi.TaskController.extend(ETahi.FileUploadMixin, {
  figureUploadUrl: ( ->
    "/papers/#{@get('litePaper.id')}/figures"
  ).property('litePaper.id')

  figures: Ember.computed.alias 'paper.figures'

  actions:
    uploadStarted: (data, fileUploadXHR) ->
      @uploadStarted(data, fileUploadXHR)
      @get('uploads').pushObject ETahi.FileUpload.create(file: data.files[0])

    uploadProgress: (data) ->
      @uploadProgress(data)
      currentUpload = @get('uploads').findBy('file', data.files[0])
      return unless currentUpload
      currentUpload.setProperties(dataLoaded: data.loaded, dataTotal: data.total)

    uploadFinished: (data, filename) ->
      @uploadFinished(data, filename)

      @store.pushPayload('figure', data)
      figure = @store.getById('figure', data.figure.id)

      @get('figures').pushObject(figure)

    cancelUploads: ->
      @cancelUploads()

    changeStrikingImage: (newValue) ->
      @get('content.paper').then (paper)->
        paper.set('strikingImageId', newValue).save()
})
