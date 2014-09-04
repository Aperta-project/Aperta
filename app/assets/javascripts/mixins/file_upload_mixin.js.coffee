ETahi.FileUploadMixin = Em.Mixin.create
  _init: (->
    @set 'uploads', []
  ).on('init')

  uploads: null

  isUploading: (->
    console.log 'isUploading', !!this.get('uploads.length')
    !!this.get('uploads.length')
  ).property('uploads.@each', 'uploads.[]')

  uploadStarted: (data, fileUploadXHR) ->
    @get('uploads').pushObject ETahi.FileUpload.create(file: data.files[0])
    @set('fileUploadXHR', fileUploadXHR)
    window.fileUploadXHR = @get('fileUploadXHR')
    $(window).on 'beforeunload', ->
      return 'You are uploading, are you sure you want to cancel?'

  uploadProgress: (data) ->

  uploadFinished: (data, filename) ->
    uploads = @get('uploads')
    newUpload = uploads.findBy('file.name', filename)
    uploads.removeObject newUpload
    $(window).off 'beforeunload'

  cancelUploads: ->
    @get('fileUploadXHR').abort()
    @set('uploads', [])
    $(window).off 'beforeunload'
