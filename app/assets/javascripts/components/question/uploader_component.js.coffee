ETahi.QuestionUploaderComponent = ETahi.QuestionComponent.extend
  layoutName: "components/question/uploader_component"
  fileUpload: null

  actions:
    uploadStarted: (data) ->
      @set('fileUpload', ETahi.FileUpload.create(file: data.files[0]))

    uploadProgress: (data) ->
      @get('fileUpload').setProperties(dataLoaded: data.loaded, dataTotal: data.total)

    uploadFinished: (data) ->
      @set('model.url', data)
      @get('model').save().then =>
        @set('fileUpload', null)

    destroyAttachment: (attachment) ->
      @sendAction 'destroyAttachment', attachment
