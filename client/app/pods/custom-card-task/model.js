import Task from 'tahi/pods/task/model';

export default Task.extend({
  cardVersion: DS.belongsTo('card-version'),
  repetitions: DS.hasMany('repetition')
});
