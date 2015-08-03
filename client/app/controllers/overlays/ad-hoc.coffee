`import Ember from 'ember'`
`import TaskController from 'tahi/pods/paper/task/controller'`
`import BuildsTaskTemplate from 'tahi/mixins/controllers/builds-task-template'`
`import FileUploadMixin from 'tahi/mixins/file-upload'`
`import RESTless from 'tahi/services/rest-less'`

AdHocOverlayController = TaskController.extend BuildsTaskTemplate, FileUploadMixin,
  blocks: Ember.computed.alias('model.body')

  imageUploadUrl: (->
    "/api/tasks/#{@get('model.id')}/attachments"
  ).property('model.id')

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
      RESTless.putModel(@get('model'), "/send_message", task: data)
      @send('saveModel')

    destroyAttachment: (attachment) ->
      attachment.destroyRecord()

    uploadFinished: (data, filename) ->
      @uploadFinished(data, filename)
      @store.pushPayload('attachment', data)

      # TODO: Remove when ember-data isn't borked
      attachment = @store.getById('attachment', data.attachment.id)
      @get('model.attachments').pushObject(attachment)

`export default AdHocOverlayController`
