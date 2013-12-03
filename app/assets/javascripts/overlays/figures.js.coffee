window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.figures =
  init: ->
    uploader = $('.js-jquery-fileupload').fileupload()
    uploader.on 'fileuploadprocessalways', @fileUploadProcessAlways
    uploader.on 'fileuploaddone', @fileUploadDone

  fileUploadProcessAlways: (event, data) ->
    file = data.files[0]
    li = $("<li data-file-id='#{file.name}'>")
    li.append(file.preview)
    li.append('<div class="progress progress-striped active">')
    li.appendTo('#paper-figure-uploads')

  fileUploadDone: (event, data) ->
    file = data.files[0]
    $("#paper-figure-uploads [data-file-id='#{file.name}']").remove()
    result = data.result[0]
    li = $("<li><img src='#{result.src}' alt='#{result.alt}' /></li>")
    $('#paper-figures').append(li)

