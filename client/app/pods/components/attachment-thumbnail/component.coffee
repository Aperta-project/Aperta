`import Ember from 'ember'`
`import SpinnerMixin from 'tahi/mixins/views/spinner'`

AttachmentThumbnailComponent = Ember.Component.extend SpinnerMixin
  classNameBindings: ['destroyState:_destroy', 'editState:_edit']
  destroyState: false
  previewState: false
  editState: false

  attachmentType: 'attachment'

  attachmentUrl: (->
    "/figures/#{@get('attachment.id')}/update_attachment"
  ).property('attachment.id')

  spinnerOpts: (->
    lines: 7 # The number of lines to draw
    length: 0 # The length of each line
    width: 7 # The line thickness
    radius: 7 # The radius of the inner circle
    corners: 1 # Corner roundness (0..1)
    rotate: 0 # The rotation offset
    direction: 1 # 1: clockwise, -1: counterclockwise
    color: '#fff' # #rgb or #rrggbb or array of colors
    speed: 1.3 # Rounds per second
    trail: 68 # Afterglow percentage
    shadow: false # Whether to render a shadow
    hwaccel: false # Whether to use hardware acceleration
    className: 'spinner' # The CSS class to assign to the spinner
    zIndex: 2e9 # The z-index (defaults to 2000000000)
    top: '50%'
    left: '50%'
  ).property()

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

  toggleSpinner: (->
    @createSpinner('showSpinner', '.replace-spinner', @get('spinnerOpts'))
  ).observes('showSpinner').on('didInsertElement')

  isProcessing: ( ->
    @get('attachment.status') == "processing"
  ).property('attachment.status')

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

