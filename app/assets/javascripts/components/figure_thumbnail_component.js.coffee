ETahi.FigureThumbnailComponent = ETahi.AttachmentThumbnailComponent.extend
  attachmentType: 'figure'

  actions:
    toggleStrikingImageFromCheckbox: (checkbox)->
      newValue = if checkbox.get('checked') then checkbox.get('attachment.id') else null
      @sendAction('action', newValue)
