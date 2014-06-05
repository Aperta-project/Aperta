ETahi.FileUploaderComponent = Ember.TextField.extend
  type: 'file'
  name: 'file'
  multiple: false
  accept: null
  filePrefix: null

  dataType: 'json'
  method: 'POST'
  bucketUrl: 'https://tahi-development.s3.amazonaws.com'

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
    params.url = @get('bucketUrl')
    params.dataType = 'xml'
    params.add = (e, uploadData) =>
      file = uploadData.files[0]
      $.ajax
        url: "/request_policy",
        type: 'GET',
        dataType: 'json',
        data: 
          file_prefix: @get('filePrefix')
          content_type: file.type
        success: (data) ->
          uploadData.formData =
            key: "#{data.key}/#{file.name}"
            policy: data.policy
            success_action_status: 201
            'Content-Type': file.type
            signature: data.signature
            AWSAccessKeyId: data.access_key_id
            acl: data.acl
          uploadData.submit()

    params.success = (data) =>
      $.ajax
        url: @get('url')
        dataType: 'json'
        type: @get('method')
        data: {url: $(data).find('Location').text()}

    uploader.fileupload(params)

    uploader.on 'fileuploadadd', (e, uploadData) =>
      Ember.run.bind(this, @checkFileType)

    uploader.on 'fileuploadstart', (e, data) =>
      @sendAction('start')

    uploader.on 'fileuploadprogress', (e, data) =>
      @sendAction('progress', data)

    uploader.on 'fileuploaddone', (e, data) =>
      @sendAction('done', data)

    uploader.on 'fileuploadsuccess', (e, data) =>
      debugger

    uploader.on 'fileuploadprocessalways', (e, data) =>
      @sendAction('process', data)
  ).on('didInsertElement')
