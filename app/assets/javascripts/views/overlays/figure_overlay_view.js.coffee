ETahi.FigureOverlayView = ETahi.OverlayView.extend
  templateName: 'overlays/figure_overlay'
  layoutName: 'layouts/overlay_layout' #TODO: include assignee here?
  figures: null
  _figures: ( ->
    @get('controller.paper').then (paper) =>
      @set('figures', paper.get('figures'))
  ).observes('controller.paper')

  setupTooltip: (->
    @.$().find('.figure-original-download-link').tooltip()
  ).on('didInsertElement')

