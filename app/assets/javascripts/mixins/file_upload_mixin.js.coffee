ETahi.FileUploadMixin = Em.Mixin.create
  _init: (->
    @set 'uploads', []
  ).on('init')

  uploads: null

  isUploading: (->
    !!this.get('uploads.length')
  ).property('uploads.@each', 'uploads.[]')

  uploadStarted: (data, fileUploadXHR) ->
    @get('uploads').pushObject ETahi.FileUpload.create(file: data.files[0], xhr: fileUploadXHR)
    $(window).on 'beforeunload.cancelUploads', ->
      return 'You are uploading, are you sure you want to cancel?'

  uploadProgress: (data) ->
    console.log "noop upload progress in file upload mixin."

  uploadFinished: (data, filename) ->
    uploads = @get('uploads')
    newUpload = uploads.findBy('file.name', filename)
    uploads.removeObject newUpload
    $(window).off 'beforeunload.cancelUploads'

  cancelUploads: ->
    @get('uploads').invoke('abort')
    @set('uploads', [])
    $(window).off 'beforeunload.cancelUploads'
