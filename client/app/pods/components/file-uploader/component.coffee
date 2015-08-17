`import Ember from 'ember'`

FileUploaderComponent = Ember.TextField.extend
  type: 'file'
  name: 'file'
  multiple: false
  accept: null
  filePrefix: null
  uploadImmediately: true

  dataType: 'json'
  method: 'POST'
  railsMethod: 'POST'

  acceptedFileTypes: ( ->
    types = @get('accept').replace(/\./g, '').replace(/,/g, '|')
    new RegExp("(#{types})$", 'i')
  ).property('accept')

  checkFileType: (e, data) ->
    if @get('accept')
      fileName = data.originalFiles[0]['name']
      if fileName.length && !@get('acceptedFileTypes').test(fileName)
        errorMessage = "Sorry! '#{data.originalFiles[0]['name']}' is not of an accepted file type"
        @set('error', errorMessage)
        @sendAction('error', errorMessage)
        e.preventDefault()

  setupUploader:(->
    uploader = @.$()

    params = @getProperties('dataType', 'method', 'acceptFileTypes')
    params.dataType = 'xml'
    params.autoUpload = false # since we're not overriding the uploader's add method, we need to prevent
                              # the form from autosubmitting before the s3 stuff has gone through first.
    params.previewMaxHeight = 90
    params.previewMaxWidth = 300
    # No matter how dumb this looks, it is necessary.
    that = @
    params.success = (fileData) ->
      filename = @files[0].name
      location = $(fileData).find('Location').text().replace(/%2F/g, "/")

      resourceUrl = that.get('url')
      requestMethod = that.get('railsMethod')
      if resourceUrl && requestMethod # tell rails server that upload to s3 finished
        $.ajax
          url: resourceUrl
          dataType: 'json'
          type: requestMethod
          data: Ember.merge({url: location}, that.get('dataParams'))
          success: (data) ->
            that.sendAction('done', data, filename)
      else # allow custom behavior when s3 upload is finished
        that.sendAction('done', location, filename)


    uploader.fileupload(params)

    uploader.on 'fileuploadadd', (e, uploadData) =>
      Ember.run.bind(this, @checkFileType)
      file = uploadData.files[0]
      self = @

      # make get request to setup s3 keys for actual upload
      $.ajax
        url: "/api/s3/request_policy",
        type: 'GET',
        dataType: 'json',
        data:
          file_prefix: @get('filePrefix')
          content_type: file.type
        success: (data) ->
          uploadData.url = data.url
          uploadData.formData =
            key: "#{data.key}/#{file.name}"
            policy: data.policy
            success_action_status: 201
            'Content-Type': file.type
            signature: data.signature
            AWSAccessKeyId: data.access_key_id
            acl: data.acl

          uploadFunction = () ->
            uploadData.process().done (data)->
              self.sendAction('start', data, uploadData.submit())

          if self.get('uploadImmediately')
            uploadFunction()
          else
            self.sendAction('uploadReady', uploadFunction)

    uploader.on 'fileuploadprogress', (e, data) =>
      @sendAction('progress', data)

    uploader.on 'fileuploadprocessstart', (e, data) =>
      @sendAction('process', data)

    uploader.on 'fileuploadprocessalways', (e, data) =>
      @sendAction('processingDone', data.files[0])

    uploader.on 'fileuploadfail', (e, data) =>
      @sendAction('error', data)
  ).on('didInsertElement')

`export default FileUploaderComponent`
