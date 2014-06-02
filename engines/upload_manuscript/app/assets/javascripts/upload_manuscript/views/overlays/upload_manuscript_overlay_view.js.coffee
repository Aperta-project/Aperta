ETahi.UploadManuscriptOverlayView = ETahi.OverlayView.extend
  templateName: 'overlays/upload_manuscript_overlay'
  layoutName: 'layouts/overlay_layout'

  spinner:(->
    new Spinner({top: '20px', left: '-30px', color: '#39a329'})
  ).property()

  setupSpinner:(->
    @get('spinner').spin($('.processing')[0])
  ).on('didInsertElement')
