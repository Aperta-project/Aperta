ETahi.AuthorsTask = ETahi.Task.extend
  authors: Ember.computed.alias('paper.authorsArray')
  qualifiedType: "StandardTasks::AuthorsTask"
  isMetadataTask: true

ETahi.FigureTask = ETahi.Task.extend
  qualifiedType: "StandardTasks::FigureTask"
  isMetadataTask: true
  figures: DS.hasMany('figure')

ETahi.TechCheckTask = ETahi.Task.extend
  qualifiedType: "StandardTasks::TechCheckTask"
