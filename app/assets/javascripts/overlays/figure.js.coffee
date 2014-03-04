Tahi.overlays.figure =
  FigureUpload: React.createClass
    render: ->
      {div, li} = React.DOM
      ProgressBar = Tahi.overlays.components.ProgressBar

      (li {}, [
        (div {className: 'preview-container'}),
        (ProgressBar {progress: @props.progress})])

    componentDidMount: (rootNode) ->
      previewContainer = $('.preview-container', rootNode)
      previewContainer.append window.tempStorage[this.props.filename]

  Overlay: React.createClass
    getInitialState: ->
      uploads: []
      figures: []

    componentWillMount: ->
      @setState @props

    componentWillReceiveProps: (nextProps) ->
      @setState nextProps

    componentWillUnmount: ->
      $("[data-card-name='figure']").data('figures', @state.figures)

    render: ->
      {main, h1, span, input, ul, li, img} = React.DOM

      RailsForm = Tahi.overlays.components.RailsForm
      FigureUpload = Tahi.overlays.figure.FigureUpload

      uploadLIs = @state.uploads.map (upload) ->
        (FigureUpload {key: upload.filename, filename: upload.filename, progress: upload.progress})

      figureLIs = @state.figures.map (figure, index) ->
        (li {key: index}, (img {src: figure.src, alt: figure.alt}))

      (main {}, [
        (h1 {}, @props.taskTitle),
        (span {className: 'secondary-button fileinput-button'}, [
          'Add new Figures',
          (RailsForm {action: "#{@props.figuresPath}.json", method: 'POST'},
            (input {
              id: 'figure_attachment',
              className: 'js-jquery-fileupload',
              multiple: 'multiple',
              name: 'figure[attachment][]',
              type: 'file'}))]),
        (ul {id: 'paper-figure-uploads'}, uploadLIs),
        (ul {id: 'paper-figures'}, figureLIs)])

    componentDidMount: (rootNode) ->
      uploader = $('.js-jquery-fileupload', rootNode).fileupload()
      uploader.on 'fileuploadprocessalways', @fileUploadProcessAlways
      uploader.on 'fileuploaddone',          @fileUploadDone
      uploader.on 'fileuploadprogress',      @fileUploadProgress

    fileUploadProcessAlways: (event, data) ->
      uploads = @state.uploads
      file = data.files[0]
      window.tempStorage ||= {}
      window.tempStorage[file.name] = file.preview
      newUploads = uploads.concat [{filename: file.name, progress: 0}]
      @setState uploads: newUploads

    fileUploadDone: (event, data) ->
      uploads = @state.uploads
      file = data.files[0]
      newUploads = uploads.filter (u) -> u.filename != file.name

      figures = @state.figures
      newFigures = figures.concat [{src: data.result[0].src, alt: data.result[0].alt}]

      window.tempStorage ||= {}
      delete window.tempStorage[file.name]

      @setState
        uploads: newUploads
        figures: newFigures

    fileUploadProgress: (event, data) ->
      uploads = @state.uploads
      currentUpload = uploads.filter((u) -> u.filename == data.files[0].name)[0]
      currentUpload.progress = data.loaded / data.total * 100.0
      @setState uploads: uploads
