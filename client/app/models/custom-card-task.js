import Task from 'tahi/models/task';

export default Task.extend({
  cardVersion: DS.belongsTo('card-version')
});
