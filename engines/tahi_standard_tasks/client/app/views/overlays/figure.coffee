`import OverlayView from 'tahi/views/overlay'`

FigureOverlayView = OverlayView.extend
  templateName: 'overlays/figure'
  layoutName: 'layouts/overlay' #TODO: include assignee here?

  setupTooltip: (->
    # @.$().find('.attachment-original-download-link').tooltip()
  ).on('didInsertElement')

`export default FigureOverlayView`

