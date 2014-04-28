ETahi.AuthorsTask = ETahi.Task.extend
  authors: Ember.computed.alias('paper.authorsArray')
  qualifiedType: "StandardTasks::AuthorsTask"

ETahi.FigureTask = ETahi.Task.extend
  qualifiedType: "StandardTasks::FigureTask"

ETahi.TechCheckTask = ETahi.Task.extend
  qualifiedType: "StandardTasks::TechCheckTask"
