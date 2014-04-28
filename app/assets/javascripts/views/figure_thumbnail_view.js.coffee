ETahi.FigureThumbnailView = Em.View.extend
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

  focusIn: (e) ->
    @set('editState', true)

  focusOut: (e) ->
    @set('editState', false)
    @get('controller.model').save()

  actions:
    cancelDestroyFigure: ->
      @set 'destroyState', false

    confirmDestroyFigure: ->
      @set 'destroyState', true

    destroyFigure: ->
      self = @
      self.$().fadeOut 250, ->
        self.get('controller').send('destroyFigure', self.get('content'))

    togglePreview: ->
      @toggleProperty 'previewState'

      @scrollToView() if @get 'previewState'
