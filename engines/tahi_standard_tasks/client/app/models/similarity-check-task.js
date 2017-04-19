import DS from 'ember-data';
import Task from 'tahi/models/task';

var SimilarityCheckTask = Task.extend({
  similarityChecks: DS.hasMany('similarity-check')
});

export default SimilarityCheckTask;
