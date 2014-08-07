ETahi.AttachmentThumbnailComponent = Ember.Component.extend
  classNameBindings: ['destroyState:_destroy', 'editState:_edit']
  destroyState: false
  previewState: false
  editState: false
  uploadingState: false

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

  scrollToView: ->
    $('.overlay').animate
      scrollTop: @$().offset().top + $('.overlay').scrollTop()
    , 500, 'easeInCubic'

  toggleSpinner: (->
    if @get('showSpinner')
      @spinnerDiv = @$('.replace-spinner')[0]
      @spinner ||= new Spinner(@get('spinnerOpts')).spin(@spinnerDiv)
      $(@spinnerDiv).show()
    else
      $(@spinnerDiv).hide()
  ).observes('showSpinner').on('didInsertElement')

  isProcessing: ( ->
    @get('attachment.status') == "processing"
  ).property('attachment.status')

  showSpinner: Ember.computed.or('isProcessing', 'uploadingState')

  actions:
    cancelEditing: ->
      @set('editState', false)
      @get('attachment').rollback()

    toggleEditState: (focusSelector)->
      @toggleProperty 'editState'
      if focusSelector
        Ember.run.later @, (->
          @$(".#{focusSelector}").focus()
        ), 150

    saveAttachment: ->
      @get('attachment').save()
      @set('editState', false)

    cancelDestroyAttachment: -> @set 'destroyState', false

    confirmDestroyAttachment: -> @set 'destroyState', true

    destroyAttachment: ->
      this.$().fadeOut 250, => @get('attachment').destroyRecord()

    attachmentUploading: ->
      @set('uploadingState', true)

    attachmentUploaded: (data) ->
      store = @get('attachment.store')
      store.pushPayload 'attachment', data
      @set('uploadingState', false)

    togglePreview: ->
      @toggleProperty 'previewState'
      @scrollToView() if @get 'previewState'
