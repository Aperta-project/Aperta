ETahi.QuestionAttachmentThumbnailComponent = ETahi.AttachmentThumbnailComponent.extend
  uploadingState: false

  actions:
    attachmentUploading: ->
      @set('uploadingState', true)

    attachmentUploaded: (data) ->
      store = @get('attachment.store')
      store.pushPayload 'questionAttachment', data
      @set('uploadingState', false)
