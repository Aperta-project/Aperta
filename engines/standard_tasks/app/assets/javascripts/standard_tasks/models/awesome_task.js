ETahi.AwesomeTask = ETahi.Task.extend({
  qualifiedType: "StandardTasks::AwesomeTask",
  awesomeAuthors: Ember.computed.alias('paper.authorsArray')
});
