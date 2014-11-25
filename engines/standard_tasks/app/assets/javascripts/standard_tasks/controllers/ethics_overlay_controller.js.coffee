ETahi.EthicsOverlayController = ETahi.TaskController.extend ETahi.SavesOnClose,
  actions:
    destroyAttachment: (attachment) ->
      attachment.destroyRecord()
