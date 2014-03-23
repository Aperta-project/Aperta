ETahi.MessageOverlayView = Ember.View.extend
  templateName: 'overlays/message_overlay'
  layoutName: 'layouts/assignee_overlay_layout'

  setupTooltips: (->
    $('.user-thumbnail').tooltip(placement: 'bottom')
  ).on('didInsertElement')
