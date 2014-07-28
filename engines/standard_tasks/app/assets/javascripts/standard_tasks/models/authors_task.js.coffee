ETahi.AuthorsTask = ETahi.Task.extend
  authors: Ember.computed.alias('paper.authorsArray')
  qualifiedType: "StandardTasks::AuthorsTask"
  isMetadataTask: true
