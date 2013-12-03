window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.figures =
  init: ->
    uploader = $('.js-jquery-fileupload').fileupload()
    uploader.on 'fileuploadprocessalways', @fileUploadProcessAlways

  fileUploadProcessAlways: (event, data) ->
    li = $('<li>')
    li.append(data.files[0].preview)
    li.append('<div class="progress progress-striped active">')
    li.appendTo('#paper-figure-uploads')

