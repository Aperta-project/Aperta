ETahi.UploadManuscriptOverlayController = ETahi.TaskController.extend
  manuscriptUploadUrl: (->
    "/papers/#{@get('litePaper.id')}/upload"
  ).property('litePaper.id')

  isUploading: false
  isProcessing: false
  uploadProgress: 0
  showProgress: true

  isEditable: (->
    !@get('paper.lockedBy') && (@get('isUserEditable') || @get('isCurrentUserAdmin'))
  ).property('paper.lockedBy', 'isUserEditable', 'isCurrentUserAdmin')

  actions:
    uploadStarted: ->
      @set('isUploading', true)

    uploadProgress: (data) ->
      progress = Math.round(data.loaded * 100 / data.total)
      @set('uploadProgress', progress)
      if progress >= 100
        @setProperties(showProgress: false, isProcessing: true)

    uploadError: (message) ->
      @set('uploadError', message)

    uploadFinished: (data) ->
      @store.pushPayload(data)
      @set('isUploading', false)
      @set('completed', true)
      @get('model').save().then(=> @send('closeAction'))
