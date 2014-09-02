ETahi.UploadManuscriptOverlayController = ETahi.TaskController.extend
  needs: ['fileUpload']
  manuscriptUploadUrl: (->
    "/papers/#{@get('litePaper.id')}/upload"
  ).property('litePaper.id')

  uploads: []
  isUploading: false
  uploadsDidChange: (->
    @set 'isUploading', !!this.get('uploads.length')
  ).observes('uploads.@each')
  isProcessing: false
  uploadProgress: 0
  showProgress: true

  isEditable: (->
    !@get('paper.lockedBy') && (@get('isUserEditable') || @get('isCurrentUserAdmin'))
  ).property('paper.lockedBy', 'isUserEditable', 'isCurrentUserAdmin')

  actions:
    uploadStarted: (data, fileUploadXHR) ->
      @get('controllers.fileUpload').send('uploadStarted', data, fileUploadXHR)
      @get('uploads').pushObject ETahi.FileUpload.create(file: data.files[0])

    uploadProgress: (data) ->
      @get('controllers.fileUpload').send('uploadProgress', data)
      progress = Math.round(data.loaded * 100 / data.total)
      @set('uploadProgress', progress)
      if progress >= 100
        @setProperties(showProgress: false, isProcessing: true)

    uploadError: (message) ->
      @set('uploadError', message)

    uploadFinished: (data, filename) ->
      @get('controllers.fileUpload').send('uploadFinished', data, filename)
      @store.pushPayload(data)
      uploads = @get('uploads')
      newUpload = uploads.findBy('file.name', filename)
      uploads.removeObject newUpload
      @set('completed', true)
      @get('model').save().then(=> @send('closeAction'))

    cancelUploads: ->
      @get('controllers.fileUpload').send('cancelUploads')
      @set('uploads', [])
