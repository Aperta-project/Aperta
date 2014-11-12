ETahi.AdHocOverlayController = ETahi.TaskController.extend ETahi.BuildsTaskTemplate, ETahi.FileUploadMixin,
  needs: ['task']
  blocks: Ember.computed.alias('body')

  imageUploadUrl: (->
    "/tasks/#{@get('model.id')}/attachments"
  ).property()

  isNewTask: Em.computed.alias 'controllers.task.isNewTask'

  actions:
    setTitle: (title) ->
      @_super(title)
      @send('saveModel')

    saveBlock: (block) ->
      @_super(block)
      @send('saveModel')

    deleteBlock: (block) ->
      @_super(block)
      unless @isNew(block)
        @send('saveModel')

    deleteItem: (item, block) ->
      @_super(item, block)
      unless @isNew(block)
        @send('saveModel')

    sendEmail: (data) ->
      ETahi.RESTless.putModel(@get('model'), "/send_message", task: data)

    destroyAttachment: (attachment) ->
      attachment.destroyRecord()

    uploadFinished: (data, filename) ->
      @uploadFinished(data, filename)

      @store.pushPayload('attachment', data)
      attachment = @store.getById('attachment', data.attachment.id)

      @get('model.attachments').pushObject(attachment)
