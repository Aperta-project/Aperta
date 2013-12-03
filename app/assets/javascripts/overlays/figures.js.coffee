window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.figures =
  init: ->
    uploader = $('.js-jquery-fileupload').fileupload()
    uploader.on 'fileuploadprocessalways', @fileUploadProcessAlways
    uploader.on 'fileuploaddone', @fileUploadDone
    uploader.on 'fileuploadprogress', @fileUploadProgress

  fileUploadProcessAlways: (event, data) ->
    file = data.files[0]
    li = $("<li data-file-id='#{file.name}'>")
    li.append(file.preview)
    progressHtml = """
      <div class="progress">
        <div class="progress-bar">
        </div>
      </div>
    """
    li.append(progressHtml)
    li.appendTo('#paper-figure-uploads')

  fileUploadDone: (event, data) ->
    file = data.files[0]
    $("#paper-figure-uploads [data-file-id='#{file.name}']").remove()
    result = data.result[0]
    li = $("<li><img src='#{result.src}' alt='#{result.alt}' /></li>")
    $('#paper-figures').append(li)

  fileUploadProgress: (event, data) ->
    file = data.files[0]
    progress = data.loaded / data.total * 100.0
    $("#paper-figure-uploads [data-file-id='#{file.name}'] .progress .progress-bar").css('width', "#{progress}%")
