ETahi.FileUploaderComponent = Ember.TextField.extend
  type: 'file'
  multiple: false
  accept: null

  dataType: 'json'
  method: 'PATCH'

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

    uploader.fileupload(@getProperties('url', 'dataType', 'method', 'acceptFileTypes'))

    uploader.on 'fileuploadadd', Ember.run.bind(this, @checkFileType)

    uploader.on 'fileuploadstart', (e, data) =>
      @sendAction('start')

    uploader.on 'fileuploadprogress', (e, data) =>
      @sendAction('progress', data)

    uploader.on 'fileuploaddone', (e, data) =>
      @sendAction('done', data)

    uploader.on 'fileuploadprocessalways', (e, data) =>
      @sendAction('process', data)
  ).on('didInsertElement')
