###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.uploadManuscript =
  init: ->
    Tahi.overlay.init 'upload-manuscript'

  createComponent: (target, props) ->
    props.uploadPaperPath = target.data('uploadPaperPath')
    Tahi.overlays.uploadManuscript.components.UploadManuscriptOverlay props

  components:
    UploadManuscriptOverlay: React.createClass
      getInitialState: ->
        uploadProgress: null

      render: ->
        Overlay = Tahi.overlays.components.Overlay
        RailsForm = Tahi.overlays.components.RailsForm
        ProgressBar = Tahi.overlays.components.ProgressBar

        {li, div} = React.DOM

        progress = parseInt(@state.uploadProgress, 10)
        uploadManuscriptProgress = if !isNaN(progress)
          content = if progress == 100
            (div {className: 'processing'}, "Processing...")
          else
            ProgressBar(progress: progress)

          (li {}, [
            (div {className: 'preview-container glyphicon glyphicon-file'}),
            content
          ])

        checkboxFormAction = "#{this.props.taskPath}.json"
        `<Overlay
            paperTitle={this.props.paperTitle}
            paperPath={this.props.paperPath}
            taskPath={this.props.taskPath}
            taskCompleted={this.props.taskCompleted}
            onOverlayClosed={this.props.onOverlayClosed}
            onCompletedChanged={this.props.onCompletedChanged}>
          <main>
            <h1>Upload Manuscript</h1>
            <h2>You may upload a manuscript at any time.</h2>
            <div id="upload-file-wrapper">
              <span className="secondary-button fileinput-button">
                Select and upload document
                <RailsForm action={this.props.uploadPaperPath}>
                  <input id='upload_file'
                         className="js-jquery-fileupload"
                         name="upload_file"
                         type="file" />
                </RailsForm>
              </span>
            </div>
            {this.state.error}
            <ul id="paper-manuscript-upload">
              {uploadManuscriptProgress}
            </ul>
          </main>
        </Overlay>`

      componentDidUpdate: (prevProps, prevState, rootNode) ->
        new Spinner(top: '0', left: '-64px', color: '#39a329').spin $('.processing', rootNode)[0]

      componentDidMount: (rootNode) ->
        uploader = $('.js-jquery-fileupload', rootNode).fileupload
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
