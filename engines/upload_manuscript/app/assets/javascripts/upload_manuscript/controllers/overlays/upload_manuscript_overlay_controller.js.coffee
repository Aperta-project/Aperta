ETahi.UploadManuscriptOverlayController = ETahi.TaskController.extend ETahi.FileUploadMixin,
  manuscriptUploadUrl: (->
    "/papers/#{@get('litePaper.id')}/upload"
  ).property('litePaper.id')

  isProcessing: false
  uploadProgress: 0
  showProgress: true

  isEditable: (->
    !@get('paper.lockedBy') && (@get('isUserEditable') || @get('isCurrentUserAdmin'))
  ).property('paper.lockedBy', 'isUserEditable', 'isCurrentUserAdmin')

  actions:
    uploadProgress: (data) ->
      @uploadProgress(data)
      progress = Math.round(data.loaded * 100 / data.total)
      @set('uploadProgress', progress)
      if progress >= 100
        @setProperties(showProgress: false, isProcessing: true)

    uploadError: (message) ->
      @set('uploadError', message)

    uploadFinished: (data, filename) ->
      @uploadFinished(data, filename)
      @store.pushPayload(data)
      @set('completed', true)
      @get('model').save().then(=> @send('closeAction'))
