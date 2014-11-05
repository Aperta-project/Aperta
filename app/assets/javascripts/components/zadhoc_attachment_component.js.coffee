ETahi.AdhocAttachmentThumbnailComponent = ETahi.AttachmentThumbnailComponent.extend
  actions:
    destroyAttachment: ->
      this.$().fadeOut 250, => @get('attachment').destroyRecord()
