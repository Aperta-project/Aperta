ETahi.FileUploadController = Em.Controller.extend
  actions:
    uploadStarted: (data, fileUploadXHR) ->
      @set('fileUploadXHR', fileUploadXHR)
      $(window).on 'beforeunload', ->
        return 'You are uploading, are you sure you want to cancel?'

    uploadProgress: (data) ->

    uploadFinished: (data, filename) ->
      $(window).off 'beforeunload'

    cancelUploads: ->
      @get('fileUploadXHR').abort()
      $(window).off 'beforeunload'
