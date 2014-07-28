ETahi.AuthorsTask = ETahi.Task.extend
  authors: Ember.computed.alias('paper.authorsArray')
  qualifiedType: "StandardTasks::AuthorsTask"
  isMetadataTask: true

ETahi.FigureTask = ETahi.Task.extend
  qualifiedType: "StandardTasks::FigureTask"
  isMetadataTask: true

ETahi.TechCheckTask = ETahi.Task.extend
  qualifiedType: "StandardTasks::TechCheckTask"

ETahi.EthicsTask = ETahi.Task.extend
  qualifiedType: "StandardTasks::EthicsTask"
