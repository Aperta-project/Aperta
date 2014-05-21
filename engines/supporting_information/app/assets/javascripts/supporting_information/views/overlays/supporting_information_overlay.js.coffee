ETahi.SupportingInformationOverlayView = ETahi.OverlayView.extend
  templateName: 'overlays/supporting_information_overlay'
  layoutName: 'layouts/overlay_layout'
  uploads: []
  supportingInformationFiles: null
  _files: ( ->
    @get('controller.paper').then (paper) =>
      @set('supportingInformationFiles', paper.get('supportingInformationFiles'))
  ).observes('controller.paper')

  setupUpload: (->
    uploader = $('.js-jquery-fileupload')
    uploader.fileupload
      url: "/supporting_information_files?paper_id=#{@controller.get('paper.id')}"
      dataType: 'json'
      method: 'POST'

    uploader.on 'fileuploadprocessalways', (e, data) =>
      file = data.files[0]

      upload =
        filename: file.name
        progress: 0
        progressBarStyle: "width: 0%;"

      if file.error
        upload.error = "There was an error uploading file: #{file.name}."

      @uploads.pushObject upload

    uploader.on 'fileuploadprogress', (e, data) =>
      currentUpload = @uploads.findBy('filename', data.files[0].name)
      progress = parseInt(data.loaded / data.total * 100.0, 10) #rounds the number
      Ember.setProperties currentUpload,
        progress: progress
        progressBarStyle: "width: #{progress}%;"

    uploader.on 'fileuploaddone', (e, data) =>
      newUpload = @uploads.findBy 'filename', data.files[0].name
      @uploads.removeObject newUpload

      store = @get('controller.store')
      updatedFiles = _.map data.result.files, (file) ->
        store.pushPayload 'supportingInformationFile', { supportingInformationFiles: [ file ] }
        store.getById('supportingInformationFile', file.id)

      @get('supportingInformationFiles').pushObjects updatedFiles

  ).on('didInsertElement')

  setupTooltip: (->
    @.$().find('.file-original-download-link').tooltip()
  ).on('didInsertElement')

