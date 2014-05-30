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
      progress = parseInt(data.loaded / data.total * 100.0, 10)
      @set('uploadProgress', progress)
      if progress >= 100
        @setProperties(showProgress: false, isProcessing: true)

    uploadError: (message) ->
      @set('uploadError', message)

    uploadFinished: ->
      @set('isUploading', false)
      @set('completed', true)
      self = @
      @get('model').save().then ->
        self.get('paper')
          .then((paper) -> paper.reload())
          .then(-> self.send('closeAction'))
