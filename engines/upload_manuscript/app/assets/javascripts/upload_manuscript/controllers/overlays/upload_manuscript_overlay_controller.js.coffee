ETahi.UploadManuscriptOverlayController = ETahi.TaskController.extend ETahi.FileUploadMixin,
  manuscriptUploadUrl: (->
    "/papers/#{@get('litePaper.id')}/upload"
  ).property('litePaper.id')

  isProcessing: false

  showProgress: true


  isEditable: (->
    !@get('paper.lockedBy') && (@get('isUserEditable') || @get('isCurrentUserAdmin'))
  ).property('paper.lockedBy', 'isUserEditable', 'isCurrentUserAdmin')

  progress: 0

  progressBarStyle: ( ->
    "width: #{@get('progress')}%;"
  ).property('progress')


  actions:
    uploadProgress: (data) ->
      @set('progress', Math.round((data.loaded / data.total) * 100))
      if @get('progress') >= 100
        setTimeout (=>
          @setProperties(showProgress: false, isProcessing: true)
        ), 500


    uploadError: (message) ->
      @set('uploadError', message)

    uploadFinished: (data, filename) ->
      @uploadFinished(data, filename)
      @store.pushPayload(data)
      @set('completed', true)
      @get('model').save().then(=> @send('closeAction'))
