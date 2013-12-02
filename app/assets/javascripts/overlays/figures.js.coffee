window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.figures =
  init: ->
    $('.js-jquery-fileupload').fileupload()
