`import Ember from 'ember'`

UploadPreviewComponent = Ember.Component.extend
  classNameBindings: [':_uploading', 'error:alert']
  file: Ember.computed.alias('upload.file')
  filename: Ember.computed.alias('file.name')

  preview: ( ->
    preview = @get('file.preview')
    preview?.toDataURL()
  ).property('file.preview')

  progress: ( ->
    Math.round(@get('upload.dataLoaded') * 100 / @get('upload.dataTotal'))
  ).property('upload.dataLoaded', 'upload.dataTotal')

  error: null

  progressBarStyle: ( ->
    "width: #{@get('progress')}%;"
  ).property('progress')


`export default UploadPreviewComponent`
