ETahi.AdHocOverlayController = ETahi.TaskController.extend ETahi.BuildsTaskTemplate,
  needs: ['task']
  blocks: Ember.computed.alias('body')

  isNew: Em.computed.alias 'controllers.task.isNew'

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
