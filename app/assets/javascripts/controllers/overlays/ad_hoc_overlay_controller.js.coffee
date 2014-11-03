ETahi.AdHocOverlayController = ETahi.TaskController.extend ETahi.BuildsTaskTemplate,
  blocks: Ember.computed.alias('body')

  imageUploadUrl: 'URL_GOES_HERE'

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

    uploadStarted: ->
      alert 'it started'

    uploadFinished: ->
      alert 'it finished'

    cancelUploads: ->
      alert 'cancel dat shiz'

    uploadProgress: ->
      console.log 'upload progressed'
