ETahi.SupportingInformationOverlayController = ETahi.TaskController.extend ETahi.FileUploadMixin,
  uploadUrl: (->
    "/supporting_information_files?paper_id=#{@get('litePaper.id')}"
  ).property('litePaper.id')

  actions:
    uploadFinished: (data, filename) ->
      @uploadFinished(data, filename)

      @store.pushPayload('supportingInformationFile', data)
      file = @store.getById('supportingInformationFile', data.supporting_information_file.id)

      @get('paper.supportingInformationFiles').pushObject(file)

    destroyAttachment: (attachment) ->
      attachment.destroyRecord()
