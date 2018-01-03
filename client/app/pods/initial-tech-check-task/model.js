import DS   from 'ember-data';
import Task from 'tahi/pods/task/model';

export default Task.extend({
  round: DS.attr('number'),
  changesForAuthorTask: DS.belongsTo('changes-for-author-task')
});
