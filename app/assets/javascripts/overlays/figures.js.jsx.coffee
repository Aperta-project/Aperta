###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.figures =
  init: ->
    Tahi.overlay.init 'figures', @createComponent

  createComponent: (target, props) ->
    props.figuresPath = target.data('figuresPath')
    props.figures = target.data('figures')
    Tahi.overlays.figures.components.FiguresOverlay props

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
        Overlay = Tahi.overlays.components.Overlay
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
        `<Overlay
            paperTitle={this.props.paperTitle}
            paperPath={this.props.paperPath}
            closeCallback={Tahi.overlays.figures.hideOverlay}
            taskPath={this.props.taskPath}
            taskCompleted={this.props.taskCompleted}
            onOverlayClosed={this.props.onOverlayClosed}
            onCompletedChanged={this.props.onCompletedChanged}>
          <main>
            <h1>Figures</h1>
            <span className="secondary-button fileinput-button">
              Add new Figures
              <RailsForm action={formAction} method="POST">
                <input id='figure_attachment'
                       className="js-jquery-fileupload"
                       multiple="multiple"
                       name="figure[attachment][]"
                       type="file" />
              </RailsForm>
            </span>
            <ul id="paper-figure-uploads">
              {uploadLIs}
            </ul>
            <ul id="paper-figures">
              {figureLIs}
            </ul>
          </main>
        </Overlay>`

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
