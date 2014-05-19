ETahi.FigureOverlayView = ETahi.OverlayView.extend
  templateName: 'overlays/figure_overlay'
  layoutName: 'layouts/overlay_layout' #TODO: include assignee here?
  uploads: []
  figures: null
  _figures: ( ->
    @get('controller.paper').then (paper) =>
      @set('figures', paper.get('figures'))
  ).observes('controller.paper')

  setupUpload: (->
    uploader = $('.js-jquery-fileupload')
    uploader.fileupload
      url: "/papers/#{@controller.get('paper.id')}/figures"
      dataType: 'json'
      acceptFileTypes: /(\.|\/)(gif|jpe?g|png|tif?f|eps)$/i
      method: 'POST'

    uploader.on 'fileuploadprocessalways', (e, data) =>
      file = data.files[0]

      upload =
        filename: file.name
        preview: file.preview?.toDataURL()
        progress: 0
        progressBarStyle: "width: 0%;"

      if file.error
        upload.error = "File #{file.name} is not an image. You may upload files with the extension .jpg, .jpeg, .gif, .png, .eps, or .tiff."

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
      updatedFigures = _.map data.result.figures, (figure) ->
        type = store.modelFor('figure')
        serializer = store.serializerFor(type.typeKey)
        record = serializer.extractSingle(store, type, {figure: figure})
        store.push 'figure', record

      @get('figures').pushObjects updatedFigures

  ).on('didInsertElement')

  setupTooltip: (->
    @.$().find('.figure-original-download-link').tooltip()
  ).on('didInsertElement')

