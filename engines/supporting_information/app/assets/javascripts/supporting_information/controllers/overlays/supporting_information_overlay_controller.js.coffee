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

    uploadFinished: (data) ->
      uploads = @get('uploads')
      newUpload = uploads.findBy('file', data.files[0])
      uploads.removeObject newUpload

      newFiles = _.map data.result.files, (file) =>
        @store.pushPayload 'supportingInformationFile', { supportingInformationFiles: [ file ] }
        @store.getById('supportingInformationFile', file.id)

      @get('paper').then (paper) ->
        paper.get('supportingInformationFiles').pushObjects(newFiles)
