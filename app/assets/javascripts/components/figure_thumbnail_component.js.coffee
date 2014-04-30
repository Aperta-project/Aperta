ETahi.FigureThumbnailComponent = Ember.Component.extend
  tagName: 'li'
  templateName: 'figure_thumbnail'
  classNames: ['figure-thumbnail']
  classNameBindings: ['destroyState:_destroy']
  destroyState: false
  previewState: false
  editState: false

  scrollToView: ->
    $('.overlay').animate
      scrollTop: @$().offset().top + $('.overlay').scrollTop()
    , 500, 'easeInCubic'

  focusIn: (e) -> @set('editState', true)
  focusOut: (e) -> @set('editState', false) unless @get('figure.isDirty')

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

    togglePreview: ->
      @toggleProperty 'previewState'
      @scrollToView() if @get 'previewState'
