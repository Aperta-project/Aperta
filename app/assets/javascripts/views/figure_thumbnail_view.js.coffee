ETahi.FigureThumbnailView = Em.View.extend
  tagName: 'li'
  templateName: 'figure_thumbnail'
  classNames: ['figure-container']
  classNameBindings: ['destroyState:destroy']

  destroyState: false

  actions:
    cancelDestroyFigure: ->
      @set 'destroyState', false

    confirmDestroyFigure: ->
      @set 'destroyState', true
