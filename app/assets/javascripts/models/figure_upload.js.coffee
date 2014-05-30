ETahi.FigureUpload = Ember.Object.extend
  filename: Ember.computed.alias('file.name')
  preview: ( ->
    preview = @get('file.preview')
    preview?.toDataURL()
  ).property('file.preview')

  progress: 0
  error: Ember.computed.alias('file.error')

  progressBarStyle: ( ->
    "width: #{@get('progress')}%;"
  ).property('progress')
