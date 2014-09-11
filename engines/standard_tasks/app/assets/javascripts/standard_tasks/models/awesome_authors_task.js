ETahi.AwesomeAuthorsTask = ETahi.Task.extend({
  qualifiedType: "StandardTasks::AwesomeAuthorsTask",
  awesomeAuthors: Ember.computed.alias('paper.authorsArray')
});
