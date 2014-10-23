ETahi.SupportingInformationOverlayView = ETahi.OverlayView.extend
  templateName: 'supporting_information/overlays/supporting_information_overlay'
  layoutName: 'layouts/overlay_layout'

  setupTooltip: (->
    @.$().find('.file-original-download-link').tooltip()
  ).on('didInsertElement')
