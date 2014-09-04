ETahi.FigureThumbnailComponent = ETahi.AttachmentThumbnailComponent.extend
  actions:
    toggleStrikingImageFromCheckbox: (checkbox)->
      newValue = if checkbox.get('checked') then checkbox.get('attachment.id') else null
      @sendAction('action', newValue)

    uploadStarted: (data, fileUploadXHR) ->
      @sendAction('uploadBegan') # FigureOverlayController catches this
      @uploadStarted(data, fileUploadXHR)

    uploadFinished: (data, filename) ->
      @sendAction('uploadEnded') # FigureOverlayController catches this
      store = @get('attachment.store')
      store.pushPayload 'figure', data
      @uploadFinished(data, filename)

    cancelUploads: ->
      @cancelUploads()
      @sendAction('uploadEnded') # FigureOverlayController catches this
