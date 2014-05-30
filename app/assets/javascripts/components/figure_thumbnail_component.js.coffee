ETahi.FigureThumbnailComponent = Ember.Component.extend
  tagName: 'li'
  templateName: 'figure_thumbnail'
  classNames: ['figure-thumbnail']
  classNameBindings: ['destroyState:_destroy']
  destroyState: false
  previewState: false
  editState: false
  uploadingState: false

  figureUrl: (->
    "/figures/#{@get('figure.id')}"
  ).property('figure.id')

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

  focusIn: (e) -> @set('editState', true)
  focusOut: (e) -> @set('editState', false) unless @get('figure.isDirty')

  toggleSpinner: (->
    if @get('uploadingState')
      @spinnerDiv = @$('.replace-spinner')[0]
      @spinner ||= new Spinner(@get('spinnerOpts')).spin(@spinnerDiv)
      $(@spinnerDiv).show()
    else
      $(@spinnerDiv).hide()
  ).observes('uploadingState')

  actions:
    saveFigure: ->
      @get('figure').save()
      @set('editState', false)

    cancelEditing: ->
      @set('editState', false)
      @get('figure').rollback()

    cancelDestroyFigure: -> @set 'destroyState', false

    confirmDestroyFigure: -> @set 'destroyState', true

    destroyFigure: ->
      this.$().fadeOut 250, => @get('figure').destroyRecord()

    figureUploading: ->
      @set('uploadingState', true)

    figureUploaded: (data) ->
      store = @get('figure.store')
      store.pushPayload 'figure', data.result
      @set('uploadingState', false)

    togglePreview: ->
      @toggleProperty 'previewState'
      @scrollToView() if @get 'previewState'
