ETahi.FileUploadMixin = Em.Mixin.create
  _init: (->
    @set 'uploads', []
    @set 'isUploading', false
  ).on('init')

  uploads: null
  isUploading: null

  uploadsDidChange: (->
    @set 'isUploading', !!this.get('uploads.length')
  ).observes('uploads.@each')

  uploadStarted: (data, fileUploadXHR) ->
    @set('fileUploadXHR', fileUploadXHR)
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
