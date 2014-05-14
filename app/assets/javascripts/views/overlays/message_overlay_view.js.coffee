ETahi.MessageOverlayView = ETahi.OverlayView.extend
  templateName: 'overlays/message_overlay'
  layoutName: 'layouts/assignee_overlay_layout'

  didInsertElement: (e) ->
    $("div.unread").bind 'inview', (e, visible) ->
      debugger



