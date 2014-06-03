ETahi.FigureOverlayView = ETahi.OverlayView.extend
  templateName: 'standard_tasks/overlays/figure_overlay'
  layoutName: 'layouts/overlay_layout' #TODO: include assignee here?

  setupTooltip: (->
    @.$().find('.figure-original-download-link').tooltip()
  ).on('didInsertElement')

