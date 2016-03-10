import DS   from 'ember-data';
import Task from 'tahi/models/task';

export default Task.extend({
  assignments: DS.hasMany('assignment', { async: false }),
  assignableRoles: DS.hasMany('assignable-role', { async: false })
});
