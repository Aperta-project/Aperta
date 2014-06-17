ETahi.SupportingInformationOverlayController = ETahi.TaskController.extend
  uploads: []

  uploadUrl: (->
    "/supporting_information_files?paper_id=#{@get('litePaper.id')}"
  ).property('litePaper.id')

  actions:
    uploadStarted: (data) ->
      @get('uploads').pushObject ETahi.FileUpload.create(file: data.files[0])

    uploadProgress: (data) ->
      currentUpload = @get('uploads').findBy('file', data.files[0])
      currentUpload.setProperties(dataLoaded: data.loaded, dataTotal: data.total)

    uploadFinished: (data, filename) ->
      uploads = @get('uploads')
      newUpload = uploads.findBy('file.name', filename)
      uploads.removeObject newUpload

      @store.pushPayload('supportingInformationFile', data)
      file = @store.getById('supportingInformationFile', data.supporting_information_file.id)

      @get('paper.supportingInformationFiles').pushObject(file)
