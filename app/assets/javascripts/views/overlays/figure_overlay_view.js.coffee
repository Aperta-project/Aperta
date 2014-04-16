ETahi.FigureOverlayView = ETahi.OverlayView.extend
  templateName: 'overlays/figure_overlay'
  layoutName: 'layouts/overlay_layout' #TODO: include assignee here?
  uploads: Ember.ArrayController.create content: []
  figures: null

  didInsertElement: ->
    @set 'figures', @get('controller.model.figures')
    uploader = $('.js-jquery-fileupload')
    uploader.fileupload
      url: "/papers/#{@controller.get('paper.id')}/figures"
      dataType: 'json'
      method: 'POST'

    uploader.on 'fileuploadprocessalways', (e, data) =>
      file = data.files[0]
      @uploads.pushObject
        filename: file.name
        preview: file.preview?.toDataURL()
        progress: 0
        progressBarStyle: "width: 0%;"


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
        store.createRecord 'figure', figure

      @figures.pushObjects updatedFigures
