ETahi.FigureThumbnailComponent = ETahi.AttachmentThumbnailComponent.extend
  actions:
    toggleStrikingImageFromCheckbox: (checkbox)->
      newValue = if checkbox.get('checked') then checkbox.get('attachment') else null
      @sendAction('action', newValue)
