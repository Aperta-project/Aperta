###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.figures =
  init: ->
    $('[data-card-name=figures]').on 'click', Tahi.overlays.figures.displayOverlay

  displayOverlay: (e) ->
    e.preventDefault()

    $target = $(e.target)
    component = Tahi.overlays.figures.components.FiguresOverlay
      paperTitle: $target.data('paperTitle')
      paperPath: $target.data('paperPath')
      figuresPath: $target.data('figuresPath')
      taskPath: $target.data('taskPath')
      figures: $target.data('figures')
      taskCompleted: $target.hasClass('completed')
      onCompletedChanged: Tahi.overlays.figures.handleCompletedChanged
    React.renderComponent component, document.getElementById('new-overlay'), Tahi.initChosen

    $('#new-overlay').show()

  hideOverlay: (e) ->
    e?.preventDefault()
    $('#new-overlay').hide()
    React.unmountComponentAtNode document.getElementById('new-overlay')

  handleCompletedChanged: (event, data) ->
    $('[data-card-name=figures]').toggleClass 'completed', data.completed

  components:
    FigureUpload: React.createClass
      render: ->
        ProgressBar = Tahi.overlays.figures.components.ProgressBar

        `<li>
          <div className="preview-container" />
          <ProgressBar progress={this.props.progress} />
        </li>`

      componentDidMount: (rootNode) ->
        previewContainer = $('.preview-container', rootNode)
        previewContainer.append window.tempStorage[this.props.filename]

    ProgressBar: React.createClass
      render: ->
        style = {width: "#{@props.progress}%"}
        `<div className="progress">
          <div className="progress-bar" style={style} />
         </div>`

    FiguresOverlay: React.createClass
      getInitialState: ->
        uploads: []
        figures: @props.figures

      render: ->
        OverlayHeader = Tahi.overlays.components.OverlayHeader
        OverlayFooter = Tahi.overlays.components.OverlayFooter
        RailsForm = Tahi.overlays.components.RailsForm
        FigureUpload = Tahi.overlays.figures.components.FigureUpload

        uploadLIs = @state.uploads.map (upload) ->
          `<FigureUpload key={upload.filename} filename={upload.filename} progress={upload.progress} />`

        figureLIs = @state.figures.map (figure, index) ->
          `<li key={index}>
            <img src={figure.src} alt={figure.alt} />
          </li>`

        formAction = "#{this.props.figuresPath}.json"
        checkboxFormAction = "#{this.props.taskPath}.json"
        inputField = `<input id='figure_attachment' className="js-jquery-fileupload" multiple="multiple" name="figure[attachment][]" type="file" />`
        `<div>
          <OverlayHeader paperTitle={this.props.paperTitle} paperPath={this.props.paperPath} closeCallback={Tahi.overlays.figures.hideOverlay} />
          <main>
            <h1>Figures</h1>
            <span className="secondary-button fileinput-button">
              Add new Figures
              <RailsForm action={formAction} formContent={inputField} method="POST" />
            </span>
            <ul id="paper-figure-uploads">
              {uploadLIs}
            </ul>
            <ul id="paper-figures">
              {figureLIs}
            </ul>
          </main>
          <OverlayFooter closeCallback={Tahi.overlays.figures.hideOverlay} checkboxFormAction={checkboxFormAction} taskCompleted={this.props.taskCompleted} onCompletedChanged={this.props.onCompletedChanged} />
        </div>`

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
