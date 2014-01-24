###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.uploadManuscript =
  init: ->
    Tahi.overlay.init 'upload-manuscript', @createComponent

  createComponent: (target, props) ->
    Tahi.overlays.uploadManuscript.components.UploadManuscriptOverlay props

  components:
    UploadManuscriptOverlay: React.createClass
      componentDidMount: (rootNode) ->
        uploader = $('.js-jquery-fileupload', rootNode).fileupload
          done: ->
            $('#task_checkbox_completed:not(:checked)').click()
            Turbolinks.visit(window.location)

      render: ->
        Overlay = Tahi.overlays.components.Overlay
        RailsForm = Tahi.overlays.components.RailsForm

        formAction = "#{this.props.paperPath}.json"
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
            <p>You may upload a manuscript at any time.</p>
            <div id="upload-file-wrapper">
              <span className="secondary-button fileinput-button">
                Select and upload document
                <RailsForm action={formAction}>
                  <input id='upload_file'
                         className="js-jquery-fileupload"
                         name="upload_file"
                         type="file" />
                </RailsForm>
              </span>
              <p className='warning'>NOTE:<br />Uploading a document will replace your current work</p>
            </div>
            <p>Or you may simply write your paper directly in Tahi's Article View. It's up to you.</p>
          </main>
        </Overlay>`
