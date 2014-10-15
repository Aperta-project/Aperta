ETahi.PlosAuthorsTask = ETahi.Task.extend
  authors: Ember.computed.alias('paper.authorsArray')
  qualifiedType: "StandardTasks::PlosAuthorsTask"
  isMetadataTask: true
