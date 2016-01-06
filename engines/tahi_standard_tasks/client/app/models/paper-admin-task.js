import DS from 'ember-data';
import Task from 'tahi/models/task';

export default Task.extend({
  admin: DS.belongsTo('user', {
    async: true
  })
});
