ETahi.QuestionUploaderComponent = ETahi.QuestionComponent.extend ETahi.FileUploadProgress,
  layoutName: "components/question/uploader_component"

  actions:
    uploadFinished: (data) ->
      @set('model.url', data)
      @get('model').save()
