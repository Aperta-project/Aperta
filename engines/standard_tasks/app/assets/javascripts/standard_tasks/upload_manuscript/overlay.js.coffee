Tahi.overlays.standardsUploadManuscript =
  Overlay: React.createClass
    getInitialState: ->
      uploadProgress: null

    render: ->
      RailsForm = Tahi.overlays.components.RailsForm
      ProgressBar = Tahi.overlays.components.ProgressBar

      {main, h1, h2, div, span, ul, li, input} = React.DOM

      progress = parseInt(@state.uploadProgress, 10)
      uploadManuscriptProgress = if !isNaN(progress)
        content = if progress == 100
          (div {className: 'processing'}, "Processing...")
        else
          (ProgressBar {progress: progress})

        (li {}, [
          (div {className: 'preview-container glyphicon glyphicon-file'}),
          content])

      (main {}, [
        (h1 {}, @props.taskTitle),
        (h2 {}, 'You may upload a manuscript at any time.'),
        (div {id: 'upload-file-wrapper'},
          (span {className: 'secondary-button fileinput-button'}, [
            'Select and upload document',
            (RailsForm {action: @props.uploadPaperPath},
              (input {
                id: 'upload_file',
                className: 'js-jquery-fileupload',
                name: 'upload_file',
                type: 'file'}))])),
        (@state.error),
        (ul {id: 'paper-manuscript-upload'}, uploadManuscriptProgress)])

    componentDidUpdate: (prevProps, prevState) ->
      new Spinner(top: '0', left: '-64px', color: '#39a329').spin $('.processing', @getDOMNode())[0]

    componentDidMount: ->
      uploader = $('.js-jquery-fileupload', @getDOMNode()).fileupload
        done: =>
          $('#task_checkbox_completed:not(:checked)').click()
          $('html').removeClass 'noscroll'
          Turbolinks.visit(@props.paperPath)
      uploader.on 'fileuploadadd',           @fileUploadAdd
      uploader.on 'fileuploadprocessalways', @fileUploadProcessAlways
      uploader.on 'fileuploadprogress',      @fileUploadProgress

    fileUploadAdd: (e, data) ->
      @setState error: null
      acceptFileTypes = /(\.|\/)(docx)$/i
      if data.originalFiles[0]['name'].length && !acceptFileTypes.test(data.originalFiles[0]['name'])
        @setState error: "Sorry! '#{data.originalFiles[0]['name']}' is not of an accepted file type"
        e.preventDefault()
      else
        data.submit()

    fileUploadProcessAlways: (event, data) ->
      unless (@state || {}).error?
        @setState uploadProgress: 0

    fileUploadProgress: (event, data) ->
      @setState uploadProgress: data.loaded / data.total * 100.0
