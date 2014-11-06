ETahi.AdhocAttachmentThumbnailComponent = ETahi.AttachmentThumbnailComponent.extend
  actions:
    destroyAttachment: ->
      this.$().fadeOut 250, =>
        @sendAction 'destroyAttachment', @get('attachment')
