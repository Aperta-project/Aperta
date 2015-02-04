`import QuestionComponent from 'tahi/pods/components/question/component'`
`import FileUpload from 'tahi/models/file-upload'`

QuestionUploaderComponent = QuestionComponent.extend
  fileUpload: null

  actions:
    uploadStarted: (data) ->
      @set('fileUpload', FileUpload.create(file: data.files[0]))

    uploadProgress: (data) ->
      @get('fileUpload').setProperties(dataLoaded: data.loaded, dataTotal: data.total)

    uploadFinished: (data) ->
      @set('model.url', data)
      @get('model').save().then =>
        @set('fileUpload', null)

    destroyAttachment: (attachment) ->
      @sendAction 'destroyAttachment', attachment

`export default QuestionUploaderComponent`
