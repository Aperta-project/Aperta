`import OverlayView from 'tahi/views/overlay'`

PaperNewOverlayView = OverlayView.extend
  templateName: 'overlays/paper-new'
  layoutName: 'layouts/blank-overlay'

  didInsertElement: ->
    $('#paper-short-title').focus()

`export default PaperNewOverlayView`
