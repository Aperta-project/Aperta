`import Ember from 'ember'`

AttachmentThumbnailComponent = Ember.Component.extend
  classNameBindings: ['destroyState:_destroy', 'editState:_edit']
  destroyState: false
  previewState: false
  editState: false

  attachmentType: 'attachment'

  attachmentUrl: (->
    "/figures/#{@get('attachment.id')}/update_attachment"
  ).property('attachment.id')

  focusOnFirstInput: (->
    if @get('editState')
      Em.run.schedule 'afterRender', @, (->
        @$('input[type=text]:first').focus()
      )
  ).observes('editState')

  scrollToView: ->
    $('.overlay').animate
      scrollTop: @$().offset().top + $('.overlay').scrollTop()
    , 500, 'easeInCubic'

  isProcessing: Ember.computed.equal('attachment.status', 'processing')

  showSpinner: Ember.computed.or('isProcessing', 'isUploading')

  actions:
    cancelEditing: ->
      @set('editState', false)
      @get('attachment').rollback()

    toggleEditState: (focusSelector)->
      @toggleProperty 'editState'

    saveAttachment: ->
      @get('attachment').save()
      @set('editState', false)

    cancelDestroyAttachment: -> @set 'destroyState', false

    confirmDestroyAttachment: -> @set 'destroyState', true

    destroyAttachment: ->
      @$().fadeOut 250, =>
        @sendAction 'destroyAttachment', @get('attachment')

    uploadStarted: (data, fileUploadXHR) ->
      @sendAction('uploadStarted', data, fileUploadXHR)

    uploadProgress: (data) ->
      @sendAction('uploadProgress', data)

    uploadFinished: (data, filename) ->
      @sendAction('uploadFinished', data, filename)

    togglePreview: ->
      @toggleProperty 'previewState'
      @scrollToView() if @get 'previewState'


`export default AttachmentThumbnailComponent`

