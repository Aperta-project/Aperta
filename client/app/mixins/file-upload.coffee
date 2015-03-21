`import Ember from 'ember'`
`import FileUpload from 'tahi/models/file-upload'`

FileUploadMixin = Ember.Mixin.create
  _initFileUpload: (->
    @set 'uploads', []
  ).on('init')

  uploads: null

  isUploading: Ember.computed.notEmpty 'uploads'

  unloadUploads: (data, filename) ->
    uploads = @get('uploads')
    newUpload = uploads.findBy('file.name', filename)
    uploads.removeObject newUpload
    $(window).off "beforeunload.cancelUploads.#{filename}"

  uploadStarted: (data, fileUploadXHR) ->
    file = data.files[0]
    filename = file.name
    @get('uploads').pushObject FileUpload.create(file: file, xhr: fileUploadXHR)
    $(window).on "beforeunload.cancelUploads.#{filename}", ->
      return 'You are uploading, are you sure you want to abort uploading?'

  uploadProgress: (data) ->
    currentUpload = @get('uploads').findBy('file', data.files[0])
    return unless currentUpload
    currentUpload.setProperties(dataLoaded: data.loaded, dataTotal: data.total)

  uploadFinished: (data, filename) ->
    if @get('figures') || @get('figures') == []
      $('.upload-preview-filename').text('Upload Complete!')
      Ember.run.later (=>
        $('.progress').fadeOut =>
          @unloadUploads(data, filename)
      ), 2000
    else
      @unloadUploads(data, filename)

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
