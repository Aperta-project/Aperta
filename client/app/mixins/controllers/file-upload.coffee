`import Ember from 'ember'`
`import FileUpload from 'tahi/models/file-upload'`

FileUploadMixin = Ember.Mixin.create
  _init: (->
    @set 'uploads', []
  ).on('init')

  uploads: null

  isUploading: Ember.computed.notEmpty 'uploads'

  uploadStarted: (data, fileUploadXHR) ->
    file = data.files[0]
    filename = file.name
    @get('uploads').pushObject FileUpload.create(file: file, xhr: fileUploadXHR)
    $(window).on "beforeunload.cancelUploads.#{filename}", ->
      return 'You are uploading, are you sure you want to cancel?'

  uploadProgress: (data) ->
    currentUpload = @get('uploads').findBy('file', data.files[0])
    return unless currentUpload
    currentUpload.setProperties(dataLoaded: data.loaded, dataTotal: data.total)

  uploadFinished: (data, filename) ->
    uploads = @get('uploads')
    newUpload = uploads.findBy('file.name', filename)
    uploads.removeObject newUpload
    $(window).off "beforeunload.cancelUploads.#{filename}"

  cancelUploads: ->
    @get('uploads').invoke('abort')
    @set('uploads', [])
    $(window).off 'beforeunload.cancelUploads'

  actions:
    uploadStarted: (data, fileUploadXHR) ->
      @uploadStarted(data, fileUploadXHR)

    uploadProgress: (data) ->
      @uploadProgress(data)

    uploadFinished: (data, filename) ->
      @uploadFinished(data, filename)

    cancelUploads: ->
      @cancelUploads()

`export default FileUploadMixin`
