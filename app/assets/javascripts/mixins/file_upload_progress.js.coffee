ETahi.FileUploadProgress = Ember.Mixin.create
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

    uploadFinished: (data) ->
      @set('isUploading', false)
      @set('completed', true)
      @super(data)
