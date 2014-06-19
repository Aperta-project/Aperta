ETahi.UploadManuscriptOverlayController = ETahi.TaskController.extend
  manuscriptUploadUrl: (->
    "/papers/#{@get('litePaper.id')}/upload"
  ).property('litePaper.id')

  isUploading: false
  isProcessing: false
  uploadProgress: 0
  showProgress: true

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

    uploadFinished: ->
      @set('isUploading', false)
      @set('completed', true)
      @get('model').save().then =>
        @get('paper')
          .then((paper) -> paper.set('status', 'processing'))
          .then(=> @send('closeAction'))
