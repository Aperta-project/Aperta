ETahi.FigureThumbnailView = Em.View.extend
  tagName: 'li'
  templateName: 'figure_thumbnail'
  classNames: ['figure-thumbnail']
  classNameBindings: ['destroyState:figure-destroy']

  destroyState: false

  actions:
    cancelDestroyFigure: ->
      @set 'destroyState', false

    confirmDestroyFigure: ->
      @set 'destroyState', true
